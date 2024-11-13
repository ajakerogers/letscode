import Foundation

class PythonRunner {
    static let shared = PythonRunner()
    private var consoleOutput = ""
    private var mainThreadState: UnsafeMutablePointer<PyThreadState>?

    private init() {
        // Initialization should be called from the main thread in your AppDelegate or @main struct
    }

    /// Initializes the Python interpreter with the necessary configuration.
    func initializePython() {
        // Ensure this is called on the main thread
        assert(Thread.isMainThread, "initializePython must be called on the main thread")

        var config = PyConfig()
        PyConfig_InitPythonConfig(&config)

        // Set program name (optional but recommended)
        if let programName = Bundle.main.executablePath {
            programName.withCString { cString in
                withUnsafeMutablePointer(to: &config) { configPtr in
                    PyConfig_SetBytesString(configPtr, &configPtr.pointee.program_name, cString)
                }
            }
        }

        // Set PYTHONHOME
        if let resourcePath = Bundle.main.resourcePath {
            let pythonHome = "\(resourcePath)/python"
            pythonHome.withCString { cString in
                withUnsafeMutablePointer(to: &config) { configPtr in
                    PyConfig_SetBytesString(configPtr, &configPtr.pointee.home, cString)
                }
            }
        }

        // Initialize the Python interpreter
        withUnsafeMutablePointer(to: &config) { configPtr in
            let status = Py_InitializeFromConfig(configPtr)
            PyConfig_Clear(configPtr)
            if PyStatus_Exception(status) != 0 {
                Py_ExitStatusException(status)
            }
        }
        print("Python Initialized")

        // Save the main thread state and release the GIL
        mainThreadState = PyEval_SaveThread()
    }

    /// Returns the console output captured during the execution of user code.
    func getConsoleOutput() -> String {
        return consoleOutput
    }

    /// Executes the user-provided Python code with the given input.
    /// - Parameters:
    ///   - code: The user's Python code as a string.
    ///   - input: The input to pass to the user's function.
    /// - Returns: The output from the user's function as a string, or `nil` if execution failed.
    func executeUserCode(_ code: String, withInput input: String) -> String? {
        // Ensure the Python interpreter is initialized
        guard mainThreadState != nil else {
            print("Python interpreter is not initialized.")
            return nil
        }

        var result: String? = nil

        // Run the code on a background thread to avoid blocking the main thread
        let executionQueue = DispatchQueue(label: "PythonExecutionQueue")
        executionQueue.sync {
            // Acquire the GIL
            PyEval_RestoreThread(mainThreadState)

            defer {
                // Release the GIL and save the thread state
                mainThreadState = PyEval_SaveThread()
            }

            // Reset console output
            consoleOutput = ""

            // Prepare the code to execute
            let fullCode = """
            import sys
            import io
            sys.stdout = io.StringIO()
            sys.stderr = io.StringIO()

            \(code)
            """

            // Ensure the code is in UTF8 format
            guard let codeCString = fullCode.cString(using: .utf8) else {
                print("Failed to convert code to C string.")
                return
            }

            // Create a new main module
            guard let mainModule = PyImport_AddModule("__main__") else {
                print("Failed to import __main__ module.")
                return
            }
            Py_IncRef(mainModule)

            guard let globals = PyModule_GetDict(mainModule) else {
                print("Failed to get globals from __main__ module.")
                Py_DecRef(mainModule)
                return
            }

            // Compile the user's code
            guard let compiledCode = Py_CompileString(codeCString, "<string>", Py_file_input) else {
                handlePythonError(prefix: "Syntax Error")
                Py_DecRef(mainModule)
                return
            }

            // Execute the compiled code
            if PyEval_EvalCode(compiledCode, globals, globals) == nil {
                handlePythonError(prefix: "Runtime Error")
                Py_DecRef(compiledCode)
                Py_DecRef(mainModule)
                return
            }
            Py_DecRef(compiledCode)

            // Capture console output
            captureConsoleOutput()

            Py_DecRef(mainModule)

            // Set result to consoleOutput
            result = consoleOutput
        }

        return result
    }

    /// Handles Python errors by fetching and appending the error message to console output.
    private func handlePythonError(prefix: String) {
        if PyErr_Occurred() != nil {
            PyErr_Print()
            var ptype: UnsafeMutablePointer<PyObject>?
            var pvalue: UnsafeMutablePointer<PyObject>?
            var ptraceback: UnsafeMutablePointer<PyObject>?
            PyErr_Fetch(&ptype, &pvalue, &ptraceback)
            PyErr_NormalizeException(&ptype, &pvalue, &ptraceback)
            if let pvalue = pvalue,
               let errorMessage = PyObject_Str(pvalue),
               let errorCString = PyUnicode_AsUTF8(errorMessage) {
                let errorString = String(cString: errorCString)
                consoleOutput += "\n\(prefix): \(errorString)"
                Py_DecRef(errorMessage)
            }
            Py_XDECREF(ptype)
            Py_XDECREF(pvalue)
            Py_XDECREF(ptraceback)
        }
    }

    /// Captures the console output from Python's stdout and stderr.
    private func captureConsoleOutput() {
        if let sysModule = PyImport_ImportModule("sys") {
            if let stdout = PyObject_GetAttrString(sysModule, "stdout"),
               let stderr = PyObject_GetAttrString(sysModule, "stderr") {
                if let getValueMethod = PyObject_GetAttrString(stdout, "getvalue") {
                    if let stdoutValue = PyObject_CallObject(getValueMethod, nil),
                       let stdoutCString = PyUnicode_AsUTF8(stdoutValue) {
                        consoleOutput += String(cString: stdoutCString)
                        Py_DecRef(stdoutValue)
                    }
                    Py_DecRef(getValueMethod)
                }
                if let getValueMethodErr = PyObject_GetAttrString(stderr, "getvalue") {
                    if let stderrValue = PyObject_CallObject(getValueMethodErr, nil),
                       let stderrCString = PyUnicode_AsUTF8(stderrValue) {
                        consoleOutput += String(cString: stderrCString)
                        Py_DecRef(stderrValue)
                    }
                    Py_DecRef(getValueMethodErr)
                }
                Py_DecRef(stdout)
                Py_DecRef(stderr)
            }
            Py_DecRef(sysModule)
        }
    }
}

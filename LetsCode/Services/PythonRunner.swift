import Foundation

class PythonRunner {
    static let shared = PythonRunner()

    private init() {
        initializePython()
    }

    func initializePython() {
        guard let resourcePath = Bundle.main.resourcePath else {
            print("Failed to find resource path.")
            return
        }

        // Enable UTF-8 mode
        setenv("PYTHONUTF8", "1", 1)

        // Disable buffered stdio
        setenv("PYTHONUNBUFFERED", "1", 1)

        // Disable writing bytecode files
        setenv("PYTHONDONTWRITEBYTECODE", "1", 1)

        // Set PYTHONHOME to the 'python' subdirectory
        let pythonHome = "\(resourcePath)/python"
        setenv("PYTHONHOME", pythonHome, 1)

        // Set PYTHONPATH to include necessary directories
        let pythonVersion = "3.13" // Replace with your actual Python version
        let pythonLib = "\(pythonHome)/lib/python\(pythonVersion)"
        let pythonLibDynload = "\(pythonLib)/lib-dynload"
        let appLib = "\(resourcePath)/app"

        let pythonPath = "\(pythonLib):\(pythonLibDynload):\(appLib)"
        setenv("PYTHONPATH", pythonPath, 1)

        print("PYTHONHOME: \(String(cString: getenv("PYTHONHOME")!))")
        print("PYTHONPATH: \(String(cString: getenv("PYTHONPATH")!))")

        // Initialize the Python interpreter
        Py_Initialize()
        print("Python Initialized")
    }

    func executeUserCode(_ code: String, withInput input: String) -> String? {
        // Acquire the GIL (Global Interpreter Lock)
        let state = PyGILState_Ensure()
        defer {
            PyGILState_Release(state)
        }

        // Ensure the code is in UTF8 format
        guard let codeCString = code.cString(using: .utf8) else {
            print("Failed to convert code to C string.")
            return nil
        }

        // Create a new main module
        guard let mainModule = PyImport_AddModule("__main__") else {
            print("Failed to import __main__ module.")
            return nil
        }

        guard let globals = PyModule_GetDict(mainModule) else {
            print("Failed to get globals from __main__ module.")
            return nil
        }

        // Compile the user's code
        guard let compiledCode = Py_CompileString(codeCString, "<string>", Py_file_input) else {
            if PyErr_Occurred() != nil {
                PyErr_Print()
            }
            print("Failed to compile user code.")
            return nil
        }

        // Execute the compiled code
        if PyEval_EvalCode(compiledCode, globals, globals) == nil {
            if PyErr_Occurred() != nil {
                PyErr_Print()
            }
            print("Failed to execute user code.")
            Py_DecRef(compiledCode)
            return nil
        }
        Py_DecRef(compiledCode)

        // Assume the user defined a function named 'user_function'
        guard let userFunction = PyDict_GetItemString(globals, "user_function") else {
            print("User function not found.")
            return nil
        }
        Py_IncRef(userFunction)

        // Prepare arguments for the function
        let argsTuple = PyTuple_New(1)
        let inputString = PyUnicode_FromString(input)
        PyTuple_SetItem(argsTuple, 0, inputString) // Note: PyTuple_SetItem steals a reference

        // Call the user's function
        guard let functionResult = PyObject_CallObject(userFunction, argsTuple) else {
            if PyErr_Occurred() != nil {
                PyErr_Print()
            }
            print("Failed to call user function.")
            Py_DecRef(argsTuple)
            Py_DecRef(userFunction)
            return nil
        }
        Py_DecRef(argsTuple)
        Py_DecRef(userFunction)

        // Convert the result to a Swift String
        if let resultCString = PyUnicode_AsUTF8(functionResult) {
            let result = String(cString: resultCString)
            Py_DecRef(functionResult)
            return result
        } else {
            print("Failed to convert function result to string.")
            Py_DecRef(functionResult)
            return nil
        }
    }
}

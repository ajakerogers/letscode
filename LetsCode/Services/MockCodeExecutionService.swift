import Foundation

class MockCodeExecutionService {
    func executeCode(_ code: String, testCases: [TestCase], completion: @escaping (CodeExecutionResponse) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let updatedTestCases = testCases.map { testCase in
                var updatedTestCase = testCase
                let nums = self.parseInput(testCase.input)
                let target = Int(testCase.input.split(separator: ";")[1]) ?? 0
                if let indices = self.twoSum(nums, target) {
                    updatedTestCase.actualOutput = "\(indices)"
                } else {
                    updatedTestCase.actualOutput = "No solution"
                }
                return updatedTestCase
            }

            let response = CodeExecutionResponse(testCaseResults: updatedTestCases, consoleOutput: "Executed code successfully")
            completion(response)
        }
    }

    private func twoSum(_ nums: [Int], _ target: Int) -> [Int]? {
        var numDict = [Int: Int]()
        for (i, num) in nums.enumerated() {
            if let index = numDict[target - num] {
                return [index, i]
            }
            numDict[num] = i
        }
        return nil
    }

    private func parseInput(_ input: String) -> [Int] {
        let numsString = input.split(separator: ";")[0]
        return numsString.split(separator: ",").compactMap { Int($0) }
    }
}

// AppViewModel.swift
import Foundation

class AppViewModel: ObservableObject {
    @Published var problems: [Problem] = []
    @Published var completedProblems: [Problem] = []
    @Published var userELO: Int = 1000

    init() {
        loadProblems()
    }

    func loadProblems() {
        problems = [
            // Easy Problem 1: Two Sum
            Problem(
                title: "Two Sum",
                description: """
                Given an array of integers `nums` and an integer `target`, return indices of the two numbers such that they add up to target.
                """,
                difficulty: "Easy",
                functionBody: "def twoSum(lst: [int], target: int)\n    # Write your function here\n    return []\n",
                testCases: [
                    TestCase(input: "2,7,11,15,9", expectedOutput: "[0, 1]"),
                    TestCase(input: "3,2,4,6", expectedOutput: "[1, 2]"),
                    TestCase(input: "3,3,6", expectedOutput: "[0, 1]")
                ]
            ),
            // Easy Problem 2: Palindrome Check
            Problem(
                title: "Palindrome Check",
                description: """
                Write a function that checks if a given string is a palindrome (reads the same backward as forward).
                """,
                difficulty: "Easy",
                functionBody: "def isPalindrome(s: str)\n    # Write your function here\n    return False\n",
                testCases: [
                    TestCase(input: "racecar", expectedOutput: "True"),
                    TestCase(input: "hello", expectedOutput: "False"),
                    TestCase(input: "madam", expectedOutput: "True")
                ]
            ),
            // Medium Problem 1: Longest Substring Without Repeating Characters
            Problem(
                title: "Longest Substring Without Repeating Characters",
                description: """
                Given a string `s`, find the length of the longest substring without repeating characters.
                """,
                difficulty: "Medium",
                functionBody: "def lengthOfLongestSubstring(s: str)\n    # Write your function here\n    return 0\n",
                testCases: [
                    TestCase(input: "abcabcbb", expectedOutput: "3"),
                    TestCase(input: "bbbbb", expectedOutput: "1"),
                    TestCase(input: "pwwkew", expectedOutput: "3")
                ]
            ),
            // Medium Problem 2: Merge Intervals
            Problem(
                title: "Merge Intervals",
                description: """
                Given an array of intervals where intervals[i] = [start, end], merge all overlapping intervals.
                """,
                difficulty: "Medium",
                functionBody: "def merge(intervals: [[int]])\n    # Write your function here\n    return []\n",
                testCases: [
                    TestCase(input: "[[1,3],[2,6],[8,10],[15,18]]", expectedOutput: "[[1,6],[8,10],[15,18]]"),
                    TestCase(input: "[[1,4],[4,5]]", expectedOutput: "[[1,5]]"),
                    TestCase(input: "[[1,4],[2,3]]", expectedOutput: "[[1,4]]")
                ]
            ),
            // Hard Problem 1: Trapping Rain Water
            Problem(
                title: "Trapping Rain Water",
                description: """
                Given n non-negative integers representing an elevation map where the width of each bar is 1, compute how much water it can trap after raining.
                """,
                difficulty: "Hard",
                functionBody: "def trap(height: [int])\n    # Write your function here\n    return 0\n",
                testCases: [
                    TestCase(input: "0,1,0,2,1,0,1,3,2,1,2,1", expectedOutput: "6"),
                    TestCase(input: "4,2,0,3,2,5", expectedOutput: "9"),
                    TestCase(input: "1,0,1", expectedOutput: "1")
                ]
            ),
            // Hard Problem 2: Median of Two Sorted Arrays
            Problem(
                title: "Median of Two Sorted Arrays",
                description: """
                Given two sorted arrays `nums1` and `nums2` of size m and n respectively, return the median of the two sorted arrays.
                """,
                difficulty: "Hard",
                functionBody: "def findMedianSortedArrays(nums1: [int], nums2: [int])\n    # Write your function here\n    return 0.0\n",
                testCases: [
                    TestCase(input: "1,3;2", expectedOutput: "2.0"),
                    TestCase(input: "1,2;3,4", expectedOutput: "2.5"),
                    TestCase(input: "0,0;0,0", expectedOutput: "0.0")
                ]
            )
        ]
    }

    func getRandomProblem(difficulty: String) -> Problem? {
        let filtered = problems.filter { $0.difficulty == difficulty }
        return filtered.randomElement()
    }
}

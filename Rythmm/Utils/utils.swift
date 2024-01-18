//
//  utils.swift
//  Rythmm
//
//  Created by Dominik Deren on 12/01/2024.
//

import Foundation

func replaceStringUsingRegex(input: String, pattern: String, replacement: String) -> String {
    do {
        // Create a regular expression
        let regex = try NSRegularExpression(pattern: pattern)

        // Perform the replacement
        let range = NSRange(input.startIndex..., in: input)
        let output = regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: replacement)
        
        return output
    } catch {
        print("Regex error: \(error)")
        return input
    }
}

func formatSecondsToMinutesAndSeconds(_ seconds: Double) -> String {
    let totalSeconds = Int(seconds)
    let minutes = totalSeconds / 60
    let remainingSeconds = totalSeconds % 60

    // Format to "mm:ss"
    return String(format: "%02d:%02d", minutes, remainingSeconds)
}

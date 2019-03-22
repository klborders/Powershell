# daily challenges created by https://edabit.com
# Difficulty: Very Easy
# Notes: The website didn't actually have powershell - so I am creating my own tests
import-module Pester

# return a sorted array
function sort_nums_ascending([array]$arr) {
    return $arr | Sort-Object
}
# Test
Describe sort_nums_ascending {
    It "Should return an ascendingly sorted array" {
        sort_nums_ascending(3,2,1) | Should be (1,2,3)
        sort_nums_ascending(4,0,0,1) | Should be (0,0,1,4)
    }
}
<#
Output:
Describing sort_nums_ascending
 [+] Should return an ascendingly sorted array 33ms
#>


# return the sum of two numbers
function addition($a, $b) {
    return ([int]$a+[int]$b)
}
# Test
Describe addition {
    It "Should return the sum of two numbers" {
        addition 1 2 | Should Be 3
        addition -20 10 | Should be -10
    }
}
<#
Output:
Describing Addition
 [+] Should return the sum of two numbers 28ms
#>


# check if a number is a multiple of 100
function multiple_of_100?($int){
    return ($int % 100) -eq 0
}
# Test
Describe multiple_of_100? {
    It "Should return true for multiples of 100" {
        multiple_of_100?(400) | Should Be True
        multiple_of_100?(10000000) | Should Be True
    }
    It "Should return false for numbers nnot multiples of 100" {
        multiple_of_100?(10001) | Should Be False
        multiple_of_100?(-1) | Should Be False
    }
}
<#
Output:
Describing multiple_of_100?
 [+] Should return true for multiples of 100 30ms
 [+] Should return false for numbers nnot multiples of 100 36ms
#>


# returns the next number from the integer passed
function increment_by_one($int) {
    return ([int]$int+1)
}
# Test
Describe increment_by_one {
    It "Should return the integer incremented by one" {
        increment_by_one(-1) | Should Be 0
        increment_by_one(100) | Should Be 101
    }
}
<#
Output:
Describing increment_by_one
 [+] Should return the integer incremented by one 28ms
#>


# Compare Strings by Sum of Characters
function compare_string_length([string]$str1, [string]$str2) {
    return $str1.length -eq $str2.length
}
# Test
Describe compare_string_length {
    It "Should return true if the strings are the same length" {
        compare_string_length '12345' '54321' | Should Be True
        compare_string_length 'apple' 'bears' | Should Be True
    }
    It "Should return false if the strings aren't the same length" {
        compare_string_length 'orange' 'the' | Should Be False
        compare_string_length 'two' 'much words' | Should Be False
    }
}
<#
Output:
Describing compare_string_length
 [+] Should return true if the strings are the same length 25ms
 [+] Should return false if the strings aren't the same length 27ms
#>


# Remove Duplicates from Array
function remove_dups([array]$arr) {
    return $arr | Sort-Object -Unique
}
# Test
Describe remove_dups {
    It "Should remove duplicate items from an array" {
        remove_dups(1,2,2,3,4,4,5) | Should Be (1,2,3,4,5)
        remove_dups('apple','orange','orange') | Should Be ('apple','orange')
    }
}
<#
Output:
Describing remove_dups
 [+] Should remove duplicate items from an array 33ms
#>


# Is the Number Less than or Equal to Zero?
function less_than_or_equal_to_zero($int) {
    return $int -le 0
}
# Test
Describe less_than_or_equal_to_zero {
    It "Should return true if the number is <= zero" {
        less_than_or_equal_to_zero(0) | Should Be True
        less_than_or_equal_to_zero(-1) | Should Be True
    }
    It "Should return false if the number is >= zero" {
        less_than_or_equal_to_zero(1) | Should Be False
        less_than_or_equal_to_zero(10) | Should Be False
    }
}
<#
Output:
Describing less_than_or_equal_to_zero
 [+] Should return true if the number is <= zero 22ms
 [+] Should return false if the number is >= zero 26ms
#>


# Return the Last Element in an Array
function get_last_item([array]$arr) {
    return $arr[-1]
}
# Test
Describe get_last_item {
    It "Should return the last item in an array" {
        get_last_item(1,2,5,10,3) | Should Be 3
        get_last_item('Turkey', 'Pig', 'Bear') | Should Be 'Bear'
    }
}
<#
Output:
Describing get_last_item
 [+] Should return the last item in an array 63ms
#>


# Find the Largest Number in an Array
function find_largest_num([array]$arr) {
    return ($arr | Measure-Object -Maximum).Maximum
}
# Test
Describe find_largest_num {
    It "Should return the largest item in an array" {
        find_largest_num(101,2,1) | Should Be 101
        find_largest_num(1,2,12,4) | Should Be 12
    }
}
<#
Output:
Describing find_largest_num
 [+] Should return the largest item in an array 28ms
#>


# Concatenate First and Last Name into One String
function concat_name([string]$first, [string]$last) {
    return "$last, $first"
}
# Test
Describe concat_name {
    It "Should return the lastname, firstname" {
        concat_name 'John' 'Doe' | Should Be 'Doe, John'
        concat_name 'Jane' 'Doe' | Should Be 'Doe, Jane'
    }
}
<#
Output:
Describing concat_name
 [+] Should return the lastname, firstname 30ms
#>
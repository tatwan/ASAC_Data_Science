# Five people through a tree · answers

| Person | Route | Leaf | Predicted | Actual | Miss |
|---|---|---:|---:|---:|---:|
| A | non-smoker yes → age 44 or under yes → age 32 or under yes | 1 | 4,341 | 4,392 | +51 |
| B | non-smoker yes → age 44 or under no → age 51 or under yes | 3 | 10,460 | 10,371 | −89 |
| C | non-smoker yes → age 44 or under no → age 51 or under no | 4 | 13,567 | 13,229 | −338 |
| D | non-smoker no → BMI 30.1 or under yes → age 40 or under yes | 5 | 18,605 | 17,905 | −700 |
| E | non-smoker no → BMI 30.1 or under no → age 44 or under no | 8 | 46,076 | 43,579 | −2,497 |

**Average miss of the tree:** (51 + 89 + 338 + 700 + 2,497) ÷ 5 = 3,675 ÷ 5 = **735 dollars**.

**Average miss of the line:** |4,392 − 3,214| = 1,178 · |10,371 − 12,679| = 2,308 · |13,229 − 15,263| = 2,034 · |17,905 − 28,402| = 10,497 · |43,579 − 36,067| = 7,512. Sum 23,529 ÷ 5 = **4,706 dollars**.

The line's worst misses are the two smokers: it adds the same amount for smoking to everyone, so it overcharges the slim smoker D by about 10,500 and undercharges smoker E, whose BMI is over 30, by about 7,500. The tree puts them in different leaves.

**How many different predictions?** Eight, one per leaf. Every person who reaches leaf 5 gets 18,605, whatever their sex, children or region.

**Which question only for smokers?** "Is BMI 30.1 or under?" For non-smokers the tree asks only about age: in these training rows BMI barely changes a non-smoker's charges, but for smokers above 30.1 it roughly doubles them (leaf 5 against 7, leaf 6 against 8). A pattern that holds for one group only is called an **interaction**.

**Below zero?** No. Each prediction is the average of real charges, and no real charge is below zero. A line has no such limit: it keeps going down as age and BMI go down.

**Bonus:** a smoker of 57 pays 46,076 with a BMI over 30.1 and 25,766 with 30.1 or under: about 20,300 more. For non-smokers, BMI does not change the prediction at all in this tree.

Most common error: following the BMI question for a non-smoker. Non-smokers never reach it.

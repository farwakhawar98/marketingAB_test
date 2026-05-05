# Marketing AB testing
A marketing A/B test measuring whether ads drove more conversions than a neutral public service announcement

## Business question
Did showing ads actually drive more conversions?

## Dataset
Marketing A/B Testing dataset from Kaggle, simple marketing campaign with experiment and control group for A/B testing, based on over 588,000 users

## Analysis
### SQL 
- Understanding the data, how is the data split between the two groups (control and experiment)?
- Calculated conversion rates considering ad exposure
- Segmented by ad frequency
- Ran a time analysis, determining best time to show ads
- Using CTE's and indexing
### Python
- used scipy.stats library
- Ran a chi-square test to validate the result
## Results
- The ad group converted at 2.55% vs 1.79% for the PSA group — a 43% relative lift, confirmed as statistically significant
- Conversion rate increases consistently with ad frequency, reaching 17% for heavy ad exposure
- Monday and the 14:00-16:00 and 20:00-21:00 windows show the strongest performance
## Limitations 
- The groups are heavily imbalanced (96% ads, 4% PSA)
- User should be cautious about direct comparison even though the chi-square test accounts for this mathematically
- There is ambiguity about how the users were assigned to the groups 
- There is also no demographic data available





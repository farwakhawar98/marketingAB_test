from scipy.stats import chi2_contingency

contingency = [
    [14423, 550154],  # ad: converted, not converted
    [420,   23104]    # psa: converted, not converted
]

chi2, p, dof, expected = chi2_contingency(contingency)
print(f"Chi-square: {chi2:.2f}, p-value: {p:.2e}")
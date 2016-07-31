>     else showWithColors (printf "Batt: %.2f%%") stateInPercentage
```

Then as before:

```bash
% runhaskell Setup.lhs configure --user
% runhaskell Setup.lhs build
% runhaskell Setup.lhs install --user
```

Battery information should be visible.

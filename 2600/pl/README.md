```
echo 'turing(state(q0, cpu(g01, g00, false)), [g01, g00, g00], Ts).' | swipl turing.pl
```

```
echo 'use_module(library(plunit)). load_test_files(turing). run_tests.' | swipl turing.pl
```

# Options

## Force specific platform config.

### desktop

```
Invoke-Command -comm ([scriptblock]::Create((irm 'git.io/init.ps1'))) -ar 'desktop'
```

### notebook

```
Invoke-Command -comm ([scriptblock]::Create((irm 'git.io/init.ps1'))) -ar 'notebook'
```

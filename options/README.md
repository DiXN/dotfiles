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


## Symlinks

```
iex (irm git.io/sym.ps1)
```

## Settings

```
iex (irm git.io/settings.ps1)
```

## Default Apps

```
iex (irm git.io/default-apps.ps1)
```

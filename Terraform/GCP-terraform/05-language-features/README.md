# 05 - Language Features

## Built-in Functions

https://www.terraform.io/docs/configuration/functions.html

Terraform includes a number of built-in functions that can be called from within expressions to transform and combine values.

Examples:
- `file()` - reads contents of a file
- `templatefile()` - reads file and renders template
- `lookup()` - retrieves value from a map
- `element()` - retrieves a single element from a list
- `concat()` - combines multiple lists into a single list

## Dynamic Blocks

https://www.terraform.io/docs/configuration/expressions/dynamic-blocks.html

Dynamic blocks allow you to dynamically construct repeatable nested blocks within resource blocks.

Useful for:
- Firewall rules
- Ingress/egress rules
- Route configurations

## Provisioners

https://www.terraform.io/docs/provisioners/index.html

Provisioners can be used to execute scripts on local or remote machines as part of resource creation or destruction.

Types:
- `local-exec` - runs command locally
- `remote-exec` - runs command on remote resource
- `file` - copies files to remote resource

**Note:** Provisioners should be used as a last resort. Use built-in resource configurations when possible.

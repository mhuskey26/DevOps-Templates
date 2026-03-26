# Terratest

Terratest is a Go library that provides patterns and helper functions for testing infrastructure.

## Setup

```bash
cd tests/terratest
go test -v -timeout 30m
```

## Benefits:
- Retry logic and error handling
- Parallel test execution
- Better test organization
- Integration with CI/CD pipelines
- Rich assertion library

## Running Tests:

```bash
# Run all tests
go test -v

# Run specific test
go test -v -run TestTerraformHelloWorldExample

# Run with timeout
go test -v -timeout 30m
```

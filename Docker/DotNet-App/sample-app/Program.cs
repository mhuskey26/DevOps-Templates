// Sample .NET 8 Minimal API Program.cs
var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHealthChecks();

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure middleware
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors();
app.UseHealthChecks("/health");

// Sample endpoints
app.MapGet("/", () => new
{
    Application = "Sample .NET 8 App",
    Version = "1.0.0",
    Environment = app.Environment.EnvironmentName,
    Timestamp = DateTime.UtcNow
});

app.MapGet("/api/data", () => new[]
{
    new { Id = 1, Name = "Item 1", Description = "First item" },
    new { Id = 2, Name = "Item 2", Description = "Second item" },
    new { Id = 3, Name = "Item 3", Description = "Third item" }
});

app.MapPost("/api/data", (DataItem item) =>
{
    return Results.Created($"/api/data/{item.Id}", item);
});

app.Run();

record DataItem(int Id, string Name, string Description);

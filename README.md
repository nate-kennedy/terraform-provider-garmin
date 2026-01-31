# Terraform Provider for Garmin Connect

A Terraform/OpenTofu provider for managing Garmin Connect workouts using Infrastructure-as-Code.

## Features

- **Declarative Workout Management**: Define workouts in HCL and apply with `terraform apply`
- **Full CRUD Support**: Create, read, update, and delete workouts
- **Workout Scheduling**: Schedule workouts on specific dates in your Garmin calendar
- **Strength Training Focus**: Comprehensive support for strength training exercises
- **State Management**: Terraform tracks your workouts and handles updates automatically

## Requirements

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- [Go](https://golang.org/doc/install) >= 1.21 (for building from source)
- [Python 3](https://www.python.org/) with [garth](https://github.com/matin/garth) (for authentication)
- Garmin Connect account

## Installation

### From Source

```bash
# Clone the repository
git clone https://github.com/nate-kennedy/terraform-provider-garmin.git
cd terraform-provider-garmin

# Build the provider
go build -o terraform-provider-garmin

# Install to local plugins directory (Linux/macOS)
mkdir -p ~/.terraform.d/plugins/local/nate-kennedy/garmin/0.1.0/$(go env GOOS)_$(go env GOARCH)
cp terraform-provider-garmin ~/.terraform.d/plugins/local/nate-kennedy/garmin/0.1.0/$(go env GOOS)_$(go env GOARCH)/
```

## Authentication

This provider uses [garth](https://github.com/matin/garth), a Python library that handles Garmin's OAuth authentication flow. You must authenticate with garth before using this provider.

### Initial Setup

1. Install garth:

```bash
pip install garth
```

2. Authenticate with Garmin (will prompt for MFA if enabled):

```bash
python3 -c "import garth; garth.login('your@email.com', 'your-password'); garth.save('~/.garth')"
```

3. Tokens are saved to `~/.garth/` and are valid for approximately 1 year.

### Provider Configuration

```hcl
terraform {
  required_providers {
    garmin = {
      source = "nate-kennedy/garmin"
    }
  }
}

provider "garmin" {
  # Uses ~/.garth by default
  # Optionally specify a different token directory:
  # garth_home = "/path/to/garth/tokens"
}
```

### Configuration Options

| Attribute | Environment Variable | Default | Description |
|-----------|---------------------|---------|-------------|
| `garth_home` | `GARTH_HOME` | `~/.garth` | Path to garth token directory |

## Usage

### Basic Workout

```hcl
resource "garmin_workout" "leg_day" {
  name        = "Leg Day"
  description = "Heavy compound leg workout"
  sport_type  = "strength_training"

  scheduled_date = "2025-01-22"

  warmup {
    duration_minutes = 5
    type             = "dynamic"
  }

  exercise {
    name         = "Back Squat"
    category     = "SQUAT"
    sets         = 5
    reps         = 5
    weight_lbs   = 185
    rest_seconds = 180
  }

  exercise {
    name         = "Romanian Deadlift"
    category     = "DEADLIFT"
    sets         = 4
    reps         = 8
    weight_lbs   = 135
    rest_seconds = 120
  }

  exercise {
    name            = "Plank"
    category        = "PLANK"
    sets            = 3
    duration_seconds = 60
    rest_seconds    = 45
  }

  cooldown {
    duration_minutes = 5
    type             = "mobility"
  }
}
```

### Exercise Categories

The following exercise categories are supported:

| Category | Description |
|----------|-------------|
| `BENCH_PRESS` | Bench press variations |
| `SQUAT` | Squat variations |
| `DEADLIFT` | Deadlift and hip hinge movements |
| `LUNGE` | Lunge variations |
| `PLANK` | Plank and isometric core |
| `SHOULDER_PRESS` | Overhead pressing movements |
| `ROW` | Rowing movements |
| `CURL` | Bicep curl variations |
| `CRUNCH` | Crunch and core movements |
| `PUSH_UP` | Push-up variations |
| `PULL_UP` | Pull-up and chin-up variations |
| `STEP_UP` | Step-up movements |
| `CALF_RAISE` | Calf raise variations |
| `HIP_RAISE` | Hip thrust, glute bridge |
| `LATERAL_RAISE` | Lateral raise movements |
| `SHRUG` | Shrug movements |
| `TRICEPS_EXTENSION` | Tricep extension variations |
| `UNKNOWN` | Other exercises |

### Rep Ranges

For exercises with rep ranges (e.g., "8-12 reps"):

```hcl
exercise {
  name         = "Overhead Press"
  category     = "SHOULDER_PRESS"
  sets         = 3
  reps_min     = 8
  reps_max     = 12
  rest_seconds = 90
}
```

### Timed Exercises

For exercises measured by duration (e.g., planks):

```hcl
exercise {
  name            = "Plank"
  category        = "PLANK"
  sets            = 3
  duration_seconds = 60
  rest_seconds    = 45
}
```

### Per-Side Exercises

For unilateral exercises:

```hcl
exercise {
  name         = "Single-Leg Deadlift"
  category     = "DEADLIFT"
  sets         = 3
  reps         = 10
  per_side     = true
  rest_seconds = 60
}
```

## Importing Existing Workouts

Import an existing Garmin workout by its ID:

```bash
terraform import garmin_workout.my_workout 123456789
```

You can find workout IDs in the Garmin Connect URL when viewing a workout.

## Workflow

```bash
# Initialize the provider
terraform init

# Preview changes
terraform plan

# Apply changes (create/update workouts)
terraform apply

# Delete all managed workouts
terraform destroy
```

## Examples

See the [examples](./examples) directory for:

- [Provider configuration](./examples/provider/)
- [Single workout examples](./examples/resources/garmin_workout/)
- [Full marathon strength program](./examples/marathon-program/)

## Limitations

- **Authentication**: Uses unofficial Garmin Connect API via garth. Tokens must be refreshed if they expire (~1 year).
- **Rate Limiting**: Garmin may rate-limit requests. The provider includes retry logic but large batches may take time.
- **Exercise Categories**: Limited to Garmin's predefined exercise categories.
- **Scheduling**: Workouts can be scheduled to dates but not specific times.

## Troubleshooting

### Authentication Failures

1. Ensure you've run garth to authenticate: `python3 -c "import garth; garth.login('email', 'pass'); garth.save('~/.garth')"`
2. Check that `~/.garth/oauth1_token.json` and `~/.garth/oauth2_token.json` exist
3. If tokens have expired, re-run the garth authentication command
4. If MFA is enabled, garth will prompt you during authentication

### Rate Limiting

If you see 429 errors:
- Wait a few minutes and retry
- Consider breaking large applies into smaller batches

### Workout Not Appearing in Garmin

1. Check that `terraform apply` completed successfully
2. Force a sync on your Garmin device
3. Check the Garmin Connect web app (connect.garmin.com)

## Development

### Building

```bash
go build -o terraform-provider-garmin
```

### Testing

```bash
go test ./...
```

### Local Development Override

Create `~/.terraformrc`:

```hcl
provider_installation {
  dev_overrides {
    "nate-kennedy/garmin" = "/path/to/terraform-provider-garmin"
  }
  direct {}
}
```

## License

MIT

## Contributing

Contributions are welcome! Please open an issue or pull request.

## Disclaimer

This provider uses an unofficial Garmin Connect API. It is not affiliated with or endorsed by Garmin. Use at your own risk. The API may change without notice.

# Easy Run - Simple single-pace workout
resource "garmin_running_workout" "easy_run" {
  name        = "Easy 5 Miler"
  description = "Recovery or base-building run"

  step {
    type           = "interval"
    distance_miles = 5.0
    pace_per_mile  = "9:00-9:30"
  }
}

# Interval Workout - 6 x 800m with recovery jogs
resource "garmin_running_workout" "intervals" {
  name        = "6 x 800m Intervals"
  description = "Speed workout with 3-minute recovery jogs"

  warmup {
    distance_miles = 1.0
    pace_per_mile  = "8:30-9:30"
  }

  repeat {
    count              = 6
    skip_last_recovery = true

    interval {
      distance_meters = 800
      pace_per_mile   = "6:15-6:35"
    }

    recovery {
      duration_seconds = 180
    }
  }

  cooldown {
    distance_miles = 1.0
    pace_per_mile  = "8:30-9:30"
  }
}

# Tempo Run - Sustained threshold effort
resource "garmin_running_workout" "tempo" {
  name        = "3 Mile Tempo"
  description = "Lactate threshold workout"

  warmup {
    distance_miles = 1.0
    pace_per_mile  = "9:00-9:30"
  }

  step {
    type           = "interval"
    distance_miles = 3.0
    pace_per_mile  = "7:15-7:30"
  }

  cooldown {
    distance_miles = 1.0
    pace_per_mile  = "9:00-9:30"
  }
}

# Long Run - Progressive pace with fast finish
resource "garmin_running_workout" "long_run" {
  name        = "Long Run with Fast Finish"
  description = "12-mile long run progressing to marathon pace"

  # First 8 miles easy
  step {
    type           = "interval"
    distance_miles = 8.0
    pace_per_mile  = "8:45-9:15"
  }

  # Miles 9-10 at moderate effort
  step {
    type           = "interval"
    distance_miles = 2.0
    pace_per_mile  = "8:00-8:30"
  }

  # Final 2 miles at marathon pace
  step {
    type           = "interval"
    distance_miles = 2.0
    pace_per_mile  = "7:30-7:45"
  }
}

# Time-based workout - Run for duration instead of distance
resource "garmin_running_workout" "timed_run" {
  name        = "45 Minute Easy Run"
  description = "Time-based recovery run"

  step {
    type             = "interval"
    duration_minutes = 45
    pace_per_mile    = "9:00-9:30"
  }
}

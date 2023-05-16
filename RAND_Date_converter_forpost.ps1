function Convert-DateTimeString {
    param (
        [Parameter(Mandatory=$true)]
        [string]$StartDate,
        
        [Parameter(Mandatory=$true)]
        [string]$StartTime,
        
        [Parameter(Mandatory=$true)]
        [string]$EndDate,
        
        [Parameter(Mandatory=$true)]
        [string]$EndTime,
        
        [Parameter(Mandatory=$false)]
        [int]$Break = 0
    )

    $startDateTime = [datetime]::ParseExact($StartDate, "dd/MM/yyyy", $null)
    $startTimeSpan = [timespan]::ParseExact($StartTime, "hh\:mm", $null)
    $endDateTime = [datetime]::ParseExact($EndDate, "dd/MM/yyyy", $null)
    $endTimeSpan = [timespan]::ParseExact($EndTime, "hh\:mm", $null)
    
    $timeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById("GMT Standard Time")
    $isDstStart = $timeZone.IsDaylightSavingTime($startDateTime)
    $isDstEnd = $timeZone.IsDaylightSavingTime($endDateTime)
    
    if ($isDstStart) {
        $dstOffsetStart = $timeZone.GetUtcOffset($startDateTime).TotalHours - 1
        $startTimeSpan = $startTimeSpan.Subtract([TimeSpan]::FromHours($dstOffsetStart))
    }
    
    if ($isDstEnd) {
        $dstOffsetEnd = $timeZone.GetUtcOffset($endDateTime).TotalHours - 1
        $endTimeSpan = $endTimeSpan.Subtract([TimeSpan]::FromHours($dstOffsetEnd))
    }
    
    $startDateTime = $startDateTime.Date.Add($startTimeSpan)
    $endDateTime = $endDateTime.Date.Add($endTimeSpan)
    
    $formattedStartDateTime = $startDateTime.ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
    $formattedEndDateTime = $endDateTime.ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
    
    $timeDifferenceHours = 0

    if ($Break -eq 0) {
        $timeDifference = $endDateTime - $startDateTime
        $timeDifferenceHours = [Math]::Round($timeDifference.TotalHours, 4)
        
        $period1StartDateTime = $startDateTime
        $period1EndDateTime = $endDateTime
        $period2StartDateTime = $null
        $period2EndDateTime = $null
    }
    else {
        if ($Break -eq 30) {
            $breakStartTime = [datetime]::ParseExact("13:00", "HH:mm", $null)
            $breakEndTime = $breakStartTime.AddMinutes($Break)
            
            if ($startDateTime -lt $breakStartTime) {
                $period1StartDateTime = $startDateTime
                $period1EndDateTime = $breakStartTime
                $period2StartDateTime = $breakEndTime
                $period2EndDateTime = $endDateTime
            }
            else {
                $period1StartDateTime = $startDateTime
                $period1EndDateTime = $breakStartTime
                $period2StartDateTime = $endDateTime.Date.Add($breakEndTime.TimeOfDay)
                $period2EndDateTime = $endDateTime
            }
            
            $timeDifference1 = $period1EndDateTime - $period1StartDateTime
            $timeDifference2 = $period2EndDateTime - $period2StartDateTime
            $timeDifferenceHours = [Math]::Round(($timeDifference1.TotalMinutes + $timeDifference2.TotalMinutes) / 60, 4)
        }
        else {
        Write-Host "Invalid break duration. Please specify 0 or 30."
        return
        }
        }
        if ($Break -eq 30){
        $formattedPeriod1StartDateTime = $period1StartDateTime.ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
        $formattedPeriod1EndDateTime = $period1EndDateTime.ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ") 
        $formattedPeriod2StartDateTime = $period2StartDateTime.ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
        $formattedPeriod2EndDateTime = $period2EndDateTime.ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")}
        else {
        $formattedPeriod1StartDateTime = $period1StartDateTime.ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
        $formattedPeriod1EndDateTime = $period1EndDateTime.ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ") 
        }


        
        $result = @{
            StartDateTime = $formattedStartDateTime
            EndDateTime = $formattedEndDateTime
            TimeDifferenceHours = $timeDifferenceHours
            Period1StartDateTime = $formattedPeriod1StartDateTime
            Period1EndDateTime = $formattedPeriod1EndDateTime
            Period2StartDateTime = $formattedPeriod2StartDateTime
            Period2EndDateTime = $formattedPeriod2EndDateTime
        }
        
        return $result
    }

    #Example usage:
    $originalStartDate = "16/05/2023"
    $originalStartTime = "05:58"
    $originalEndDate = "16/05/2023"
    $originalEndTime = "11:34"
    $breakDuration = 0
    
    $convertedDateTime = Convert-DateTimeString -StartDate $originalStartDate -StartTime $originalStartTime -EndDate $originalEndDate -EndTime $originalEndTime -Break $breakDuration
    
    Write-Host "Start Date/Time: $($convertedDateTime.StartDateTime)"
    Write-Host "End Date/Time: $($convertedDateTime.EndDateTime)"
    Write-Host "Time Difference (hours): $($convertedDateTime.TimeDifferenceHours)"
    
    if ($breakDuration -eq 0) {
    Write-Host "Period 1 Start Date/Time: $($convertedDateTime.Period1StartDateTime)"
    Write-Host "Period 1 End Date/Time: $($convertedDateTime.Period1EndDateTime)"
    }
    else {
    Write-Host "Period 1 Start Date/Time: $($convertedDateTime.Period1StartDateTime)"
    Write-Host "Period 1 End Date/Time: $($convertedDateTime.Period1EndDateTime)"
    Write-Host "Period 2 Start Date/Time: $($convertedDateTime.Period2StartDateTime)"
    Write-Host "Period 2 End Date/Time: $($convertedDateTime.Period2EndDateTime)"
    }
        
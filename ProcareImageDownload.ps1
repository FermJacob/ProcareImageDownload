# Header pulled from the website in chrome dev tools when pulling a GET API call
$headers = @{Authorization = "Bearer {Token}" }
# Folder path that needs to exist 

$dateFrom = "2020-09-01"
$dateTo = "2023-01-30"
$kids = @("{GUID}", "{GUID2}")
$ExtractPath = "C:\Users\{Username}\Desktop\Procare Download\"

if (![System.IO.Directory]::Exists($ExtractPath)) {
    Write-Host "Folder path does not exist.  Please create it" 
    return
}
$page = 1
$list = [System.Collections.Arraylist]@()
for ($i = 0; $i -lt $page; $i++) {
    # Set the photos app.  NOTE: This will only pull items that are tagged as photos not learning activities with pictures
    # Note: Change date range for info you would like
    $url = "https://api-school.kinderlime.com/api/web/parent/photos/?page=$page&filters[photo][datetime_from]=$dateFrom%2000:00&filters[photo][datetime_to]=$dateTo%2023:59"
    $response = Invoke-RestMethod -ContentType "application/json; charset=utf-8" -Uri $url  -Method "GET" -Headers $headers -UseBasicParsing
    foreach ($item in $response.photos) {
        [void]$list.Add([PSCustomObject]@{
                URL       = $item.main_url
                CreatedAt = $item.created_at
            })
    }
    if ($page * $response.per_page -lt $response.total ) {
        $page = $page + 1
    }
}

# List of GUIDs for the kid ID
# Which is apart of the URL
# https://api-school.kinderlime.com/api/web/parent/daily_activities/?kid_id={kidID}&filters%5Bdaily_activity%5D%5Bdate_to%5D=2023-01-24&page=1
foreach ($kid in $kids) {
    $page1 = 1
    for ($i1 = 0; $i1 -lt $page1; $i1++) {
        # Note: Change date range for info you would like
        $url1 = "https://api-school.kinderlime.com/api/web/parent/daily_activities/?kid_id=$kid&filters%5Bdaily_activity%5D%5Bdate_to%5D=$dateTo&page=$page1"
        $response1 = Invoke-RestMethod -ContentType "application/json; charset=utf-8" -Uri $url1  -Method "GET" -Headers $headers -UseBasicParsing
        if ($response1.daily_activities.Count -gt 0) {
            foreach ($activity in $response1.daily_activities) {
                if ($null -ne $activity.photo_url) {
                    [void]$list.Add([PSCustomObject]@{
                            URL       = $activity.photo_url
                            CreatedAt = $activity.activity_date
                        })
                }
            }
            $page1 = $page1 + 1
        }
        
    }
}

$count = 1;
foreach ($photo in $list) {
    $firstResult = Split-Path $photo.URL -leaf
    $secondResult = $firstResult.Split('?')[0]
    if ($secondResult -contains ".jpg") {
        #Do Nothing
    }
    else {
        $secondResult = $secondResult + ".jpg"
    }

    $filePath = $ExtractPath + $secondResult
    if (-not(Test-Path -Path $filePath -PathType Leaf)) {
        Write-Host "Downloading item $count"
        Invoke-WebRequest -Uri $photo.URL -OutFile $filePath 
    }
    else {
        Write-Host "Item Exists $count"
    }

    # Update the CreatedAt, LastWriteTime, LastAccessTime
    (Get-Item $filePath).CreationTimeUtc = ($photo.CreatedAt)
    (Get-Item $filePath).LastAccessTimeUtc = ($photo.CreatedAt)
    (Get-Item $filePath).LastWriteTimeUtc = ($photo.CreatedAt)
    $count = $count + 1
}

function Expression {

    [CmdletBinding()]
    param (
        [int]$a,
        [int]$b,
        [int]$c
    )

    $arr = @(
        $a + $b + $c
        $a * $b * $c
        ($a + $b) * $c
        $a * ($b + $c)
    )

    return ($arr | Measure-Object -Maximum).Maximum

}

function RowSumOddNumbers([int] $n) {
  
   return [Math]::pow($n, 3)
}


function maxTriSum (){

    param (
        [int[]]$numbers
    )

    ($numbers | Sort-Object -Unique -Descending | Select-Object -First 3 | Measure-Object -Sum).Sum

    
}

# maxTriSum @(3, 2, 2, 1)

function seven([long]$m) 
{
  $steps = 0
    while ([Math]::Abs($m) -gt 99) {

        $x = [Math]::Floor($m / 10)
        $y = $m % 10
        $m = $x - (2 * $y)
        $steps += 1      

    }

    return @($m, $steps)
}

# seven 371

function max-rot($n)
{
    $number = $n.ToString()
    [long] $max = $n

    for ($i = 0; $i -lt ($number.Length - 1); $i++) {

        $number = $number.Substring(0, $i) + $number.Substring($i + 1) + $number[$i]     
        $max = [Math]::Max($max, $number)

    }

    return $max
}

function movie([int]$card, [int]$ticket, [double]$percent)
{
    $n = 0
    $sumA = 0
    $sumB = $card
    while ($sumB -ge $sumA)
    {
        $sumA += $ticket
        $sumB += ($ticket * [Math]::Pow($percent, $n + 1))
        $n++
    }
    return $n
}

function accum($s)
{
    $accum = @()

    for ($i = 0; $i -lt $s.Length; $i++) {
        
        $part = [System.String]::new($s[$i], $i + 1).ToLower()
        $part = $part.Substring(0, 1).ToUpper() + $part.Substring(1)
        $accum += $part

    }

    return $accum -join '-'
    
}



function contain-all-rots($strng, $arr) {     

    $rotation = $strng

    if($strng -eq ""){
        return true
    }
 
    for ($i = 0; $i -lt $strng.Length; $i++) {
        
        
        if(-not ($arr -contains $rotation))
        {
            return $false
        }

        $rotation = $rotation.Substring(1) + $rotation[0] 
    }

    return $true
}

contain-all-rots XjYABhR @("TzYxlgfnhf", "yqVAuoLjMLy", "BhRXjYA", "YABhRXj", "hRXjYAB", "jYABhRX", "XjYABhR", "ABhRXjY")
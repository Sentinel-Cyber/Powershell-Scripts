## Collecting Variable Info

$name = Read-Host "What is the weapon or attack name?"
$bonus = Read-Host "What is the bonus to hit? e.g 2,4,8, etc"
$dice = "1d20"
$type = Read-Host "Is this attack Ranged or Melee?"
if ($type -eq "Melee")
    {
        $range = "reach"
    }
    else
    {
        $range = "range"
    }
$reach = Read-Host "What is the attack range for this attack? e.g 5 ft for melee or 80/320 ft for ranged"
$targetnumber = Read-Host "How many targets does this attack have? e.g One, Two, Etc"
$averagehit = Read-Host "What is the average damage of this attack? e.g 7, 12, etc"
$damdice = Read-Host "What is the attacks damage dice? e.g 1d8, 2d12, etc"
$dambonus = Read-Host "What is the bonus to damage for this attack? e.g 2,4,8, etc"
$damtype = Read-Host "What is the damage type for this attack? Acid, Bludgeoning, Cold, Fire, Force, Lightning, Necrotic, Piercing, Poison, Psychic, Radiant, Slashing, Thunder, or custom types."
$addeffect = Read-Host "Does this attack have an additional damaging effect like poison damage etc? (yes or no)"

## Building Formula

if ($addeffect -like "yes")
    {
    $effname = Read-Host "What is the effects name? e.g Bite, etc"
    $effdamavg = Read-Host "What is the average damage for the effect? e.g 2,4,8"
    $effdamdice = Read-Host "What is the effects damage dice? e.g 1d8, 2d12, etc"
    $effdamtype = Read-Host "What is the damage type for this effect? Acid, Bludgeoning, Cold, Fire, Force, Lightning, Necrotic, Piercing, Poison, Psychic, Radiant, Slashing, Thunder, or custom types."

    Set-Clipboard -Value "$name. $type Weapon Attack: [rollable]+$bonus;{`"diceNotation`":`"$dice+$bonus`",`"rollType`":`"to hit`",`"rollAction`":`"$name`"}[/rollable] to hit, $range $reach., $targetnumber target. Hit: $averagehit [rollable]($damdice + $dambonus);{`"diceNotation`":`"$damdice+$dambonus`",`"rollType`":`"damage`",`"rollAction`":`"$name`",`"rollDamageType`":`"$damtype`"}[/rollable] $damtype damage plus $effdamavg [rollable]($effdamdice);{`"diceNotation`":`"$effdamdice`",`"rollType`":`"damage`",`"rollAction`":`"$effname`",`"rollDamageType`":`"$effdamtype`"}[/rollable] $effdamtype damage."
    Read-Host "Attack Formula has been copied to your clipboard. You can now paste into your homebrew creature. Press Enter to close script."
    }
    else
    {
    Set-Clipboard -Value "$name. $type Weapon Attack: [rollable]+$bonus;{`"diceNotation`":`"$dice+$bonus`",`"rollType`":`"to hit`",`"rollAction`":`"$name`"}[/rollable] to hit, $range $reach., $targetnumber target. Hit: $averagehit [rollable]($damdice + $dambonus);{`"diceNotation`":`"$damdice+$dambonus`",`"rollType`":`"damage`",`"rollAction`":`"$name`",`"rollDamageType`":`"$damtype`"}[/rollable] $damtype damage."
    Read-Host "Attack Formula has been copied to your clipboard. You can now paste into your homebrew creature. Press Enter to close script."
    }
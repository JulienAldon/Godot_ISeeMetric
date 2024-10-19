# Root like

Root like is a multiplayer PVP game where players must control the map or fullfill their hidden goal to win.

Root like is a real time strategy game where each faction plays a different gameplay. It is greatlty inspired on the board game Root.

The game is written in `gdscript` with `godot engine`.

# Game design intentions
Each faction can :
- have an aggressive strategy : low econnomy and fast attacking units
- have a defensive strategy : high economy and big defensive units

The prototype will have 3 basic factions : 
- King
- Farmer
- Church

## Factions
### King
#### Units
##### Bio (aggressive)
- Ranger : fast, ranged, low damage, high attack speed, low cost
- Marauder : medium fast, ranged, high damage, medium attack speed, medium cost

##### Mechanics (defensive)
- Tanks : slow, high range, high area damage, low attack speed, high cost
- Juggernaut : slow, no range, high damage, medium attack speed, high cost

##### Fleet (in air)
- Medic
- Ingeneer
- Protector

#### Buildings
- Barracks 
- Factory
- SpacePort
- Extractors

#### Upgrades
Upgrades can be purchased in buildings :
- Attacks (3 tier)
- Defence (3 tier)
- Bio speed boost 
- Mecha range
- Support speed (3 tier)

#### Outpost interactions
Can purchase buildings and place them in the outpost slots.

### Farmer
#### Units 
#### Buildings
##### Turrets
- Basic turret
##### Supports
- Stat support (add nearby turrets stats)
- Effect support (add nearby turrets effect)
- Turret support (changes nearby turrets behaviour)

#### Upgrades
Each Turrets and support can be individually upgraded :
3 tier defence and 3 tier offence

#### Outpost interaction
Can place permanent buildings inside oupost range effect.

The king is managing units and productions to overcome its enemies. He is greatly dependent on outposts to produce units and resources. The king hidden goal is total victory : no more units on the map.

The farmer is managing buildings and their placement to defend or attack. While farmers can place buildings everywhere, outpost allow farmers to place permanent buildings around them. The farmer's hidden goal is to keep at least 1 economy building 

The church is managing its influence with weak building defended by auto controlled units.
The church's hidden goal is to trigger and win a crusade to each players present : a crusade is an attack move order of all cultist to a single point. A crusade is failled if all units are killed, it is successfull when the outpost being attacked is taken by the cultists
Crusade can be triggered with faith : the church currency
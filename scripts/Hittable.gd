extends CharacterBody2D

class_name Hittable

## The force of the hit knockback vector
@export
var hitForce = 10

## The amount of time for which the entity is invulnerable, in seconds
@export
var invulnerabilityDuration = 1

## Invoked by a hitter when damage should be taken
signal on_damage_taken(damage : int, hitterPosition : Vector2)

## Invoked by the dying entity
signal on_death(dyingEntity : Hittable)

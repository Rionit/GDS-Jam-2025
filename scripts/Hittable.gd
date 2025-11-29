extends CharacterBody2D

class_name Hittable

## The force of the hit knockback vector
@export
var hitForce = 10

## The amount of time for which the entity is invulnerable, in seconds
@export
var invulnerabilityDuration = 1

func take_damage(damage : int, hitterPosition : Vector2):
	pass

## Invoked by the dying entity
signal on_death(dyingEntity : Hittable)

extends CharacterBody2D

class_name Hittable

const MONEY = preload("uid://twbsjtl2vg06")

## The force of the hit knockback vector
@export
var hitForce = 10

## The amount of time for which the entity is invulnerable, in seconds
@export
var invulnerabilityDuration = 1

var isInvulnerable = false

var isDying = false

var isKnockedBack = false


func take_damage(damage : int, hitterPosition : Vector2):
	pass

func take_knockback(hitterPosition : Vector2):
	isKnockedBack = true
	var knockbackVector = (global_position - hitterPosition).normalized()
	velocity = knockbackVector * hitForce * 80
	
	await get_tree().create_timer(0.6).timeout
	isKnockedBack = false

func gain_invulnerability():
	isInvulnerable = true
	await get_tree().create_timer(invulnerabilityDuration).timeout
	isInvulnerable = false
	

## Invoked by the dying entity
signal on_death(dyingEntity : Hittable)

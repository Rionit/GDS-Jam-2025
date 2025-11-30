extends CharacterBody2D

class_name Hittable

const MONEY = preload("uid://twbsjtl2vg06")

## The force of the hit knockback vector
@export
var hitForce = 10

## The amount of time for which the entity is invulnerable, in seconds
@export
var invulnerabilityDuration = 1.0

@export
var damage = 10

## Weapon hitbox of the hittable component, used to check for hits
@export
var weaponHitbox : Area2D

@export
var price = 0

var isInvulnerable = false

var isDying = false

var isKnockedBack = false

## To be implemented in respective classes
func take_damage(damage : int, hitterPosition : Vector2):
	pass
	
func _ready():
	if damage > 0:
		weaponHitbox.area_entered.connect(check_hit)
	
	
func check_hit(potentialTarget : Area2D):
	var parent = potentialTarget.get_parent()
	if parent is Hittable && \
	!(parent as Hittable).isInvulnerable && \
	!(parent as Hittable).isDying:
		(parent as Hittable).take_damage(damage, global_position)

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

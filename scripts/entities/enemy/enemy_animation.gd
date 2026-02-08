class_name EnemyAnimation
extends Node

var animations : Dictionary = {
	DirectionEnum.Value.UP: {
		StateEnum.Value.IDLE: "idle_up",
		StateEnum.Value.WALK: "walk_up",
		StateEnum.Value.ATTACK: "attack_up",
		StateEnum.Value.RUN: "run_up",
		StateEnum.Value.HURT: "hurt_up"
	},
	DirectionEnum.Value.DOWN: {
		StateEnum.Value.IDLE: "idle_down",
		StateEnum.Value.WALK: "walk_down",
		StateEnum.Value.ATTACK: "attack_down",
		StateEnum.Value.RUN: "run_down",
		StateEnum.Value.HURT: "hurt_down"
	},
	DirectionEnum.Value.LEFT: {
		StateEnum.Value.IDLE: "idle_left",
		StateEnum.Value.WALK: "walk_left",
		StateEnum.Value.ATTACK: "attack_left",
		StateEnum.Value.RUN: "run_left",
		StateEnum.Value.HURT: "hurt_left"
	},
	DirectionEnum.Value.RIGHT: {
		StateEnum.Value.IDLE: "idle_right",
		StateEnum.Value.WALK: "walk_right",
		StateEnum.Value.ATTACK: "attack_right",
		StateEnum.Value.RUN: "run_right",
		StateEnum.Value.HURT: "hurt_right"
	},
	DirectionEnum.Value.NONE: {
		StateEnum.Value.IDLE: "idle_down",
		StateEnum.Value.WALK: "idle_down",
		StateEnum.Value.ATTACK: "idle_down",
		StateEnum.Value.RUN: "run_down",
		StateEnum.Value.HURT: "hurt_down"
	}
}

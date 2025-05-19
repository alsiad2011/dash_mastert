extends CharacterBody2D

const SPEED = 1000.0        # زيادة السرعة الأساسية
const MIN_DASH_FORCE = 600.0  # أقل قوة للداش
const MAX_DASH_FORCE = 3000.0  # أقصى قوة للداش
const DASH_CHARGE_RATE = 200.0  # معدل شحن الداش
const FRICTION = 800.0     # زيادة الاحتكاك لإيقاف أسرع

var is_dashing = false
var dash_timer = 0.0
const DASH_DURATION = 0.3  # مدة الداش

var is_charging_dash = false
var dash_charge = 0.0
var max_charge_time = 2.0  # أقصى وقت شحن (ثانيتين)

@onready var player_dasher: CharacterBody2D = $"."

func _physics_process(delta: float) -> void:
	# Look at mouse position
	look_at(get_global_mouse_position())
	
	# Handle dash charging
	if Input.is_action_pressed("shift") and not is_dashing:
		if not is_charging_dash:
			is_charging_dash = true
			dash_charge = 0.0
		
		# زيادة شحنة الداش
		dash_charge += delta
		dash_charge = min(dash_charge, max_charge_time)
		
		# يمكنك إضافة تأثير بصري هنا لإظهار مستوى الشحن
		# print("Charging dash: ", dash_charge / max_charge_time * 100, "%")
	
	# Execute dash when shift is released
	if Input.is_action_just_released("shift") and is_charging_dash:
		shift_attack()
		is_charging_dash = false
	
	# تقليل وقت الـ dash
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	
	# Handle movement (إذا لم يكن في حالة dash أو شحن)
	if not is_dashing and not is_charging_dash:
		# Get input direction for top-down movement
		var input_direction = Vector2.ZERO
		
		if Input.is_action_pressed("right"):
			input_direction.x += 1
		if Input.is_action_pressed("left"):
			input_direction.x -= 1
		if Input.is_action_pressed("down"):
			input_direction.y += 1
		if Input.is_action_pressed("up"):
			input_direction.y -= 1
		
		# Normalize diagonal movement
		input_direction = input_direction.normalized()
		
		# Apply movement
		if input_direction != Vector2.ZERO:
			velocity = input_direction * SPEED
		else:
			# Apply friction when not moving
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	elif is_charging_dash:
		# إبطاء الحركة أثناء الشحن
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta * 2)
	
	move_and_slide()

func shift_attack():
	# حساب قوة الداش بناءً على وقت الشحن
	var charge_percentage = dash_charge / max_charge_time
	var dash_force = lerp(MIN_DASH_FORCE, MAX_DASH_FORCE, charge_percentage)
	
	# تطبيق قوة الـ dash في اتجاه الماوس
	var dash_direction = (get_global_mouse_position() - global_position).normalized()
	velocity = dash_direction * dash_force
	is_dashing = true
	dash_timer = DASH_DURATION
	
	# إعادة تعيين الشحن
	dash_charge = 0.0
	
	# يمكنك إضافة تأثيرات صوتية أو بصرية هنا
	# print("Dash executed with force: ", dash_force)

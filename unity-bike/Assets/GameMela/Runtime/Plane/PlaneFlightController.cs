using UnityEngine;

namespace GameMela.Runtime.Plane
{
    [RequireComponent(typeof(Rigidbody))]
    public sealed class PlaneFlightController : MonoBehaviour
    {
        [SerializeField] private float engineAcceleration = 18f;
        [SerializeField] private float maxSpeed = 95f;
        [SerializeField] private float pitchTorque = 14f;
        [SerializeField] private float rollTorque = 20f;
        [SerializeField] private float yawTorque = 7f;
        [SerializeField] private float liftCoefficient = 0.018f;
        [SerializeField] private float throttle;
        [SerializeField] private Vector2 stick;
        private Rigidbody body;

        public void SetThrottle(float value) => throttle = Mathf.Clamp01(value);
        public void SetStick(Vector2 value) => stick = Vector2.ClampMagnitude(value, 1f);
        public float SpeedKph => body == null ? 0f : body.velocity.magnitude * 3.6f;

        private void Awake()
        {
            body = GetComponent<Rigidbody>();
            body.interpolation = RigidbodyInterpolation.Interpolate;
            body.useGravity = true;
        }

        private void FixedUpdate()
        {
            float speed = body.velocity.magnitude;
            if (speed < maxSpeed)
                body.AddForce(transform.forward * (throttle * engineAcceleration), ForceMode.Acceleration);
            float lift = speed * speed * liftCoefficient;
            body.AddForce(transform.up * lift, ForceMode.Acceleration);
            body.AddRelativeTorque(new Vector3(-stick.y * pitchTorque, stick.x * yawTorque,
                -stick.x * rollTorque), ForceMode.Acceleration);
        }
    }
}
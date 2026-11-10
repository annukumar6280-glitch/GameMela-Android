using UnityEngine;

namespace GameMela.Runtime.Car
{
    [RequireComponent(typeof(Rigidbody))]
    public sealed class CarDriveController : MonoBehaviour
    {
        [SerializeField] private WheelCollider frontLeft, frontRight, rearLeft, rearRight;
        [SerializeField] private float motorTorque = 850f;
        [SerializeField] private float brakeTorque = 1800f;
        [SerializeField] private float maxSpeedKph = 190f;
        [SerializeField] private float maxSteerAngle = 30f;
        [SerializeField] private float downforce = 35f;
        [SerializeField] private float steering;
        [SerializeField] private float throttle;
        [SerializeField] private bool braking;
        private Rigidbody body;

        public float SpeedKph => body == null ? 0f : body.velocity.magnitude * 3.6f;
        public void SetSteering(float value) => steering = Mathf.Clamp(value, -1f, 1f);
        public void SetThrottle(float value) => throttle = Mathf.Clamp01(value);
        public void SetBrake(bool value) => braking = value;

        private void Awake()
        {
            body = GetComponent<Rigidbody>();
            body.interpolation = RigidbodyInterpolation.Interpolate;
            body.collisionDetectionMode = CollisionDetectionMode.ContinuousDynamic;
            body.centerOfMass += Vector3.down * 0.35f;
        }

        private void FixedUpdate()
        {
            float speedFactor = Mathf.Clamp01(SpeedKph / Mathf.Max(1f, maxSpeedKph));
            float steerAngle = steering * maxSteerAngle * Mathf.Lerp(1f, 0.45f, speedFactor);
            if (frontLeft != null) frontLeft.steerAngle = steerAngle;
            if (frontRight != null) frontRight.steerAngle = steerAngle;

            float drive = SpeedKph < maxSpeedKph ? throttle * motorTorque * (1f - speedFactor * 0.5f) : 0f;
            if (rearLeft != null) rearLeft.motorTorque = drive * 0.5f;
            if (rearRight != null) rearRight.motorTorque = drive * 0.5f;
            float brake = braking ? brakeTorque : 0f;
            SetBrake(frontLeft, brake); SetBrake(frontRight, brake);
            SetBrake(rearLeft, brake); SetBrake(rearRight, brake);
            body.AddForce(-transform.up * (SpeedKph * downforce), ForceMode.Force);
        }

        private static void SetBrake(WheelCollider wheel, float value)
        {
            if (wheel != null) wheel.brakeTorque = value;
        }
    }
}
using UnityEngine;

namespace GameMela.Runtime.Train
{
    [RequireComponent(typeof(Rigidbody))]
    public sealed class TrainDriveController : MonoBehaviour
    {
        [SerializeField] private float acceleration = 5f;
        [SerializeField] private float maxSpeed = 32f;
        [SerializeField] private float serviceBrake = 12f;
        [SerializeField] private Transform trackForward;
        [SerializeField] private float trackCorrection = 8f;
        [SerializeField] private float throttle;
        [SerializeField] private bool braking;

        private Rigidbody body;
        public float SpeedKph => body == null ? 0f : body.velocity.magnitude * 3.6f;
        public void SetThrottle(float value) => throttle = Mathf.Clamp01(value);
        public void SetBrake(bool value) => braking = value;

        private void Awake()
        {
            body = GetComponent<Rigidbody>();
            body.interpolation = RigidbodyInterpolation.Interpolate;
            body.collisionDetectionMode = CollisionDetectionMode.Continuous;
        }

        private void FixedUpdate()
        {
            if (trackForward == null) return;
            Vector3 forward = trackForward.forward;
            float speed = Vector3.Dot(body.velocity, forward);
            float force = braking ? -serviceBrake : throttle * acceleration;
            if (speed < maxSpeed || force < 0f)
                body.AddForce(forward * force, ForceMode.Acceleration);
            Vector3 lateral = body.velocity - Vector3.Project(body.velocity, forward);
            body.AddForce(-lateral * trackCorrection, ForceMode.Acceleration);
        }
    }
}
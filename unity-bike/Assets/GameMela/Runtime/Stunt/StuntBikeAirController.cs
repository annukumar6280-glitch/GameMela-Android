using UnityEngine;

namespace GameMela.Runtime.Stunt
{
    [RequireComponent(typeof(Rigidbody))]
    public sealed class StuntBikeAirController : MonoBehaviour
    {
        [SerializeField] private float pitchTorque = 18f;
        [SerializeField] private float rollTorque = 15f;
        [SerializeField] private float yawTorque = 8f;
        [SerializeField] private float landingImpactLimit = 12f;
        private Rigidbody body;
        private bool airborne;

        public void SetAirborne(bool value) => airborne = value;
        public void ApplyTrickInput(Vector2 input, float yaw)
        {
            if (!airborne) return;
            body.AddRelativeTorque(new Vector3(input.y * pitchTorque, yaw * yawTorque,
                -input.x * rollTorque), ForceMode.Acceleration);
        }

        private void Awake()
        {
            body = GetComponent<Rigidbody>();
            body.interpolation = RigidbodyInterpolation.Interpolate;
            body.collisionDetectionMode = CollisionDetectionMode.ContinuousDynamic;
        }

        private void OnCollisionEnter(Collision collision)
        {
            if (!airborne) return;
            float impact = collision.relativeVelocity.magnitude;
            if (impact > landingImpactLimit)
                Debug.LogWarning($"Hard stunt landing: {impact:0.0} m/s");
            airborne = false;
        }
    }
}
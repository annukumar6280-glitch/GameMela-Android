using UnityEngine;

/// <summary>
/// WheelCollider-based motorcycle controller foundation.
/// Requires a Rigidbody, front/rear WheelColliders and matching visual wheel meshes.
/// Tune values per production bike prefab in the Unity Inspector.
/// </summary>
[RequireComponent(typeof(Rigidbody))]
public sealed class BikeVehicleController : MonoBehaviour
{
    [Header("Wheel physics")]
    [SerializeField] private WheelCollider frontWheel;
    [SerializeField] private WheelCollider rearWheel;
    [SerializeField] private Transform frontWheelVisual;
    [SerializeField] private Transform rearWheelVisual;

    [Header("Input and handling")]
    [SerializeField] private BikeMobileInput mobileInput;
    [SerializeField, Min(1f)] private float maxSteerAngle = 28f;
    [SerializeField, Min(0f)] private float motorTorque = 420f;
    [SerializeField, Min(0f)] private float brakeTorque = 900f;
    [SerializeField, Min(0f)] private float maxSpeedKph = 115f;
    [SerializeField, Min(0f)] private float leanTorque = 7f;
    [SerializeField, Min(0f)] private float stabilityAssist = 2.5f;

    [Header("Audio")]
    [SerializeField] private AudioSource engineAudio;
    [SerializeField] private AudioSource hornAudio;
    [SerializeField] private float idlePitch = 0.85f;
    [SerializeField] private float maxPitch = 1.65f;

    private Rigidbody body;
    public float SpeedKph => body == null ? 0f : body.velocity.magnitude * 3.6f;

    private void Awake()
    {
        body = GetComponent<Rigidbody>();
        body.interpolation = RigidbodyInterpolation.Interpolate;
        body.collisionDetectionMode = CollisionDetectionMode.ContinuousDynamic;
        body.centerOfMass += new Vector3(0f, -0.35f, 0f);
    }

    private void FixedUpdate()
    {
        if (frontWheel == null || rearWheel == null || mobileInput == null)
            return;

        float steer = Mathf.Clamp(mobileInput.Steering, -1f, 1f);
        float speedFactor = Mathf.InverseLerp(0f, maxSpeedKph, SpeedKph);
        float throttle = mobileInput.Throttle && SpeedKph < maxSpeedKph ? 1f : 0f;

        frontWheel.steerAngle = steer * maxSteerAngle;
        rearWheel.motorTorque = throttle * motorTorque * (1f - speedFactor * 0.65f);

        float braking = mobileInput.Brake ? brakeTorque : 0f;
        frontWheel.brakeTorque = braking * 0.55f;
        rearWheel.brakeTorque = braking;

        float leanStrength = Mathf.Lerp(0.15f, 1f, speedFactor);
        body.AddTorque(transform.forward * (-steer * leanTorque * leanStrength),
            ForceMode.Acceleration);

        Vector3 localAngularVelocity = transform.InverseTransformDirection(body.angularVelocity);
        body.AddTorque(transform.right * (-localAngularVelocity.z * stabilityAssist),
            ForceMode.Acceleration);

        UpdateEngineAudio(throttle);
    }

    private void LateUpdate()
    {
        UpdateWheelVisual(frontWheel, frontWheelVisual);
        UpdateWheelVisual(rearWheel, rearWheelVisual);
    }

    private static void UpdateWheelVisual(WheelCollider wheel, Transform visual)
    {
        if (wheel == null || visual == null) return;
        wheel.GetWorldPose(out Vector3 position, out Quaternion rotation);
        visual.SetPositionAndRotation(position, rotation);
    }

    private void UpdateEngineAudio(float throttle)
    {
        if (engineAudio == null) return;
        float load = Mathf.Clamp01(SpeedKph / Mathf.Max(1f, maxSpeedKph) + throttle * 0.25f);
        engineAudio.pitch = Mathf.Lerp(idlePitch, maxPitch, load);
        if (!engineAudio.isPlaying) engineAudio.Play();
    }

    public void RequestHorn()
    {
        if (hornAudio == null || hornAudio.isPlaying) return;
        hornAudio.Play();
    }

    private void OnDisable()
    {
        if (engineAudio != null) engineAudio.Stop();
        if (hornAudio != null) hornAudio.Stop();
    }
}

using UnityEngine;

/// <summary>
/// Lightweight third-person follow camera. Replace with a Cinemachine rig
/// for the final scene while preserving target framing.
/// </summary>
public sealed class BikeFollowCamera : MonoBehaviour
{
    [SerializeField] private Transform target;
    [SerializeField] private Vector3 localOffset = new Vector3(0f, 3.2f, -6.8f);
    [SerializeField, Min(0.01f)] private float positionSmoothTime = 0.12f;
    [SerializeField, Min(0f)] private float lookHeight = 1.1f;
    [SerializeField, Min(0.01f)] private float rotationSharpness = 8f;

    private Vector3 positionVelocity;

    private void LateUpdate()
    {
        if (target == null) return;

        Vector3 desiredPosition = target.TransformPoint(localOffset);
        transform.position = Vector3.SmoothDamp(
            transform.position, desiredPosition, ref positionVelocity, positionSmoothTime);

        Vector3 lookPoint = target.position + target.up * lookHeight + target.forward * 2f;
        Vector3 direction = lookPoint - transform.position;
        if (direction.sqrMagnitude < 0.001f) return;

        Quaternion desiredRotation = Quaternion.LookRotation(direction.normalized, target.up);
        transform.rotation = Quaternion.Slerp(
            transform.rotation, desiredRotation, 1f - Mathf.Exp(-rotationSharpness * Time.deltaTime));
    }

    public void SetTarget(Transform newTarget) => target = newTarget;
}

using UnityEngine;

/// <summary>
/// Touch-HUD input bridge. Wire UI Button Pointer Down/Up events
/// to the public press/release methods.
/// </summary>
public sealed class BikeMobileInput : MonoBehaviour
{
    public float Steering { get; private set; }
    public bool Throttle { get; private set; }
    public bool Brake { get; private set; }

    public void PressLeft() => Steering = -1f;
    public void PressRight() => Steering = 1f;
    public void ReleaseSteering() => Steering = 0f;
    public void PressThrottle() => Throttle = true;
    public void ReleaseThrottle() => Throttle = false;
    public void PressBrake() => Brake = true;
    public void ReleaseBrake() => Brake = false;

    public void ResetInput()
    {
        Steering = 0f;
        Throttle = false;
        Brake = false;
    }

    private void OnDisable() => ResetInput();
}

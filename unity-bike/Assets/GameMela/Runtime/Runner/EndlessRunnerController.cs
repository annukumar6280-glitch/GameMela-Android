using UnityEngine;

namespace GameMela.Runtime.Runner
{
    [RequireComponent(typeof(CharacterController))]
    public sealed class EndlessRunnerController : MonoBehaviour
    {
        [SerializeField] private float forwardSpeed = 9f;
        [SerializeField] private float laneWidth = 2.4f;
        [SerializeField] private float laneChangeSpeed = 12f;
        [SerializeField] private float jumpHeight = 2.2f;
        [SerializeField] private float gravity = -22f;
        private CharacterController character;
        private int lane = 1;
        private float verticalVelocity;

        private void Awake() => character = GetComponent<CharacterController>();
        public void MoveLeft() => lane = Mathf.Max(0, lane - 1);
        public void MoveRight() => lane = Mathf.Min(2, lane + 1);
        public void Jump()
        {
            if (character.isGrounded) verticalVelocity = Mathf.Sqrt(jumpHeight * -2f * gravity);
        }

        private void Update()
        {
            if (character.isGrounded && verticalVelocity < 0f) verticalVelocity = -2f;
            verticalVelocity += gravity * Time.deltaTime;
            float targetX = (lane - 1) * laneWidth;
            float lateral = Mathf.Clamp((targetX - transform.position.x) * laneChangeSpeed, -12f, 12f);
            Vector3 motion = new Vector3(lateral, verticalVelocity, forwardSpeed);
            character.Move(motion * Time.deltaTime);
        }
    }
}
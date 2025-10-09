import runpod
import subprocess
import os
import json

# 🚀 Handler principal para procesar peticiones entrantes
def generate_video(job):
    """Recibe el prompt JSON y lanza la inferencia de video."""
    try:
        inputs = job["input"]
        prompt = inputs.get("prompt", "a modern living room, cinematic lighting")
        output_path = "/workspace/output.mp4"

        # Llama al script original de inferencia del modelo
        command = [
            "python3",
            "scripts/inference.py",
            "--prompt", prompt,
            "--output", output_path,
            "--num_frames", "24",
            "--fps", "24"
        ]

        subprocess.run(command, check=True)

        # Devuelve el resultado al endpoint
        return {
            "status": "success",
            "prompt": prompt,
            "video_path": output_path
        }

    except Exception as e:
        return {"status": "error", "message": str(e)}


# 🚦 Inicia el servidor serverless
runpod.serverless.start({"handler": generate_video})

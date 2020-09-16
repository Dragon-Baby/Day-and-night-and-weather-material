using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
[ExecuteInEditMode]public class PrecipitationManager : MonoBehaviour
{
    [System.Serializable]
    public class EnvironmentParticlesSettings
    {
        [Range(0, 1)] public float amount = 0.0f;
        public Color color = Color.white;

        [Tooltip("Alpha = variation amount")]
        public Color colorVariation = Color.white;
        public float fallSpeed;
        public Vector2 cameraRange;
        public Vector2 flutterFrequency;
        public Vector2 flutterSpeed;
        public Vector2 flutterMagnitude;
        public Vector2 sizeRange;

        public EnvironmentParticlesSettings(Color color, Color colorVariation, float fallSpeed, Vector2 cameraRange, Vector2 flutterFrequency, Vector2 flutterSpeed, Vector2 flutterMagnitude, Vector2 sizeRange)
        {
            this.color = color;
            this.colorVariation = colorVariation;
            this.fallSpeed = fallSpeed;
            this.cameraRange = cameraRange;
            this.flutterFrequency = flutterFrequency;
            this.flutterSpeed = flutterSpeed;
            this.flutterMagnitude = flutterMagnitude;
            this.sizeRange = sizeRange;
        }
    }

    public Texture2D mainTexture;
    public Texture2D noiseTexture;

    [Range(0, 1)] public float windStrength;
    [Range(-180, 180)] public float windYRotation;

    [Range(2, 256)] public int meshSubdivisions = 200;

    public EnvironmentParticlesSettings rain = new EnvironmentParticlesSettings(
        Color.white, Color.white, 3,  // color, colorVariation, fall speed
        new Vector2(0, 15), //camera range
        new Vector2(0.988f, 1.234f), //flutter frequency
        new Vector2(.01f, .01f), //flutter speed
        new Vector2(.35f, .25f), //flutter magnitude
        new Vector2(.5f, 1f)//, //size range 
    );

    public EnvironmentParticlesSettings snow = new EnvironmentParticlesSettings(
        Color.white, Color.white, .25f,  // color, colorVariation, fall speed
        new Vector2(0, 10), //camera range
        new Vector2(0.988f, 1.234f), //flutter frequency
        new Vector2(1f, .5f), //flutter speed
        new Vector2(.35f, .25f), //flutter magnitude
        new Vector2(.05f, .025f)//, //size range 
);

    GridHandler gridHandler;
    Mesh meshToDraw;

    Matrix4x4[] renderMatrices = new Matrix4x4[3 * 3 * 3];

    Material rainMaterial, snowMaterial;

    static Material CreateMaterialIfNull(string shaderName, ref Material reference)
    {
        if(reference==null)
        {
            reference = new Material(Shader.Find(shaderName));
            reference.hideFlags = HideFlags.HideAndDontSave;
            reference.renderQueue = 3000;
            reference.enableInstancing = true;
        }
        return reference;
    }

    private void OnEnable()
    {
        PrecipitationManagerEditor.ifRain = false;
        PrecipitationManagerEditor.ifSnow = false;
        rain.amount = 0;
        snow.amount = 0;
        gridHandler = GetComponent<GridHandler>();
        gridHandler.onPlayerGridChange += OnPlayerGridChange;
    }

    private void OnDisable()
    {
        gridHandler.onPlayerGridChange -= OnPlayerGridChange;
    }

    void OnPlayerGridChange(Vector3Int playerGrid)
    {
        int i = 0;

        for(int x = -1;x<=1;x++)
        {
            for(int y = -1;y<=1;y++)
            {
                for(int z = -1;z<=1;z++)
                {
                    Vector3Int neighborOffset = new Vector3Int(x, y, z);

                    renderMatrices[i++].SetTRS(gridHandler.GetGridCenter(playerGrid + neighborOffset), Quaternion.identity, Vector3.one);
                }
            }
        }
    }

    private void Update()
    {
        if (meshToDraw == null)
        {
            RebuildPrecipitationMesh();
        }

        if (!PrecipitationManagerEditor.ifRain)
        {
            if (rain.amount >= 0)
                rain.amount -= Time.deltaTime * 0.1f;
            if (rain.amount < 0)
            {
                rain.amount = 0;
            }
        }
        else if (PrecipitationManagerEditor.ifRain)
        {
            if (rain.amount <= 1)
                rain.amount += Time.deltaTime * 0.1f;
            if (rain.amount > 1)
            {
                rain.amount = 1;
                PrecipitationManagerEditor.ifRain = !PrecipitationManagerEditor.ifRain;
            }
        }
        if (!PrecipitationManagerEditor.ifSnow)
        {
            if (snow.amount >= 0)
                snow.amount -= Time.deltaTime * 0.1f;
            if (snow.amount < 0)
            {
                snow.amount = 0;
            }
        }
        else if (PrecipitationManagerEditor.ifSnow)
        {
            if (snow.amount <= 1)
                snow.amount += Time.deltaTime * 0.1f;
            if (snow.amount > 1)
            {
                snow.amount = 1;
                PrecipitationManagerEditor.ifSnow = !PrecipitationManagerEditor.ifSnow;
            }
        }

        float windStrengthAngle = Mathf.Lerp(0, 45, windStrength);

        Vector3 windRotationEulerAngles = new Vector3(-windStrengthAngle, windYRotation, 0);

        Matrix4x4 windRotationMatrix = Matrix4x4.TRS(Vector3.zero, Quaternion.Euler(windRotationEulerAngles), Vector3.one);

        float maxTravelDistance = gridHandler.gridSize / Mathf.Cos(windStrengthAngle * Mathf.Deg2Rad);

        RenderEnvironmentParticles(rain, CreateMaterialIfNull("Unlit/Rain", ref rainMaterial), maxTravelDistance, windRotationMatrix);
        RenderEnvironmentParticles(snow, CreateMaterialIfNull("Unlit/Snow", ref snowMaterial), maxTravelDistance, windRotationMatrix);

    }
    void RenderEnvironmentParticles(EnvironmentParticlesSettings settings ,Material material, float maxTravelDistance, Matrix4x4 windRotationMatrix)
    {
        if(settings.amount <= 0)
        {
            return;
        }

        material.SetTexture("_MainTex", mainTexture);
        material.SetTexture("_NoiseTex", noiseTexture);

        material.SetFloat("_GridSize", gridHandler.gridSize);
        material.SetFloat("_Amount", settings.amount);
        material.SetColor("_Color", settings.color);
        material.SetColor("_ColorVariation", settings.colorVariation);
        material.SetFloat("_FallSpeed", settings.fallSpeed);
        material.SetVector("_FlutterFrequency", settings.flutterFrequency);
        material.SetVector("_FlutterSpeed", settings.flutterSpeed);
        material.SetVector("_FlutterMagnitude", settings.flutterMagnitude);
        material.SetVector("_CameraRange", settings.cameraRange);
        material.SetVector("_SizeRange", settings.sizeRange);

        material.SetMatrix("_WindRotationMatrix", windRotationMatrix);

        material.SetFloat("_MaxTravelDistance", maxTravelDistance);
        Graphics.DrawMeshInstanced(meshToDraw, 0, material, renderMatrices, renderMatrices.Length, null, ShadowCastingMode.Off, true, 0, null, LightProbeUsage.Off);

    }

    public void RebuildPrecipitationMesh()
    {
        Mesh mesh = new Mesh();
        List<int> indices = new List<int>();
        List<Vector3> vertices = new List<Vector3>();
        List<Vector3> uvs = new List<Vector3>();

        float f = 100.0f / meshSubdivisions;
        int i = 0;
        for(float x = 0.0f; x <= 100.0f; x += f)
        {
            for(float y = 0.0f;y <= 100.0f; y += f)
            {
                float x01 = x / 100.0f;
                float y01 = y / 100.0f;

                vertices.Add(new Vector3(x01 - 0.5f, 0, y01 - 0.5f));

                float vertexIntensityThreshold = Mathf.Max((float)((x/f)%4.0f)/4.0f, (float)((y / f) % 4.0f) / 4.0f);

                uvs.Add(new Vector3(x01, y01, vertexIntensityThreshold));

                indices.Add(i++);
            }
        }

        mesh.SetVertices(vertices);
        mesh.SetUVs(0, uvs);
        mesh.SetIndices(indices.ToArray(), MeshTopology.Points, 0);

        mesh.bounds = new Bounds(Vector3.zero, new Vector3(500, 500, 500));

        mesh.hideFlags = HideFlags.HideAndDontSave;

        meshToDraw = mesh;
    }
}

#if UNITY_EDITOR
[CustomEditor(typeof(PrecipitationManager))]
public class PrecipitationManagerEditor : Editor
{
    public static bool ifRain = false;
    public static bool ifSnow = false;
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if(GUILayout.Button("Rebuild Precipitation Mesh"))
        {
            (target as PrecipitationManager).RebuildPrecipitationMesh();

            EditorUtility.SetDirty(target);
        }
        if(GUILayout.Button("Start Rain"))
        {
            ifRain = !ifRain;
        }
        if (GUILayout.Button("Start Snow"))
        {
            ifSnow = !ifSnow;
        }
    }
}
#endif 

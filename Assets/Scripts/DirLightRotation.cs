using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DirLightRotation : MonoBehaviour
{
    public float UpDownSpeed = 3.0f;
    public float EastWestSpeed = 2.0f;
    public float darkAndClearSpeed = 1.0f;
    void Update()
    {
        transform.Rotate(new UnityEngine.Vector3(Time.deltaTime * UpDownSpeed * 10.0f, 0,  0), Space.Self);
        transform.Rotate(new UnityEngine.Vector3(0, Time.deltaTime * EastWestSpeed * 10.0f, 0), Space.Self);
        if (PrecipitationManagerEditor.ifPrecipitaion)
        {
            if (GetComponent<Light>().intensity >= 0.5f)
            {
                GetComponent<Light>().intensity -= Time.deltaTime * darkAndClearSpeed * 0.1f;
            }
            if (GetComponent<Light>().intensity < 0.5f)
            {
                GetComponent<Light>().intensity = 0.5f;
            }
        }
        else
        {
            if (GetComponent<Light>().intensity <= 1.0f)
            {
                GetComponent<Light>().intensity += Time.deltaTime * darkAndClearSpeed * 0.1f;
            }
            if (GetComponent<Light>().intensity > 1.0f)
            {
                GetComponent<Light>().intensity = 1.0f;
            }
        }
    }
}

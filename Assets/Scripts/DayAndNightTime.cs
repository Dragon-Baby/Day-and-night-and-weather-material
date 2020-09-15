using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DayAndNightTime : MonoBehaviour
{
    public Material material;
    float count = 0.0f;
    public float speed = 1.0f;

    private void Update()
    {
        material.SetFloat("_SliceRange", count);
        count += Time.deltaTime * speed;
        if (count >= 7.0f)
        {
            count = 0.0f;
        }

        float darkFactor = 0.0f;
        if(PrecipitationManagerEditor.ifPrecipitaion)
        {
            if(darkFactor <= 0.5f)
            {
                material.SetFloat("_DarkFactor", darkFactor);
                darkFactor += Time.deltaTime * 0.1f;
                if (darkFactor > 0.5f)
                {
                    darkFactor = 0.5f;
                }
            }
        }
        else if(!PrecipitationManagerEditor.ifPrecipitaion)
        {
            if (darkFactor >= 0.0f)
            {
                material.SetFloat("_DarkFactor", darkFactor);
                darkFactor -= Time.deltaTime * 0.1f;
            }
            if (darkFactor < 0.0f)
            {
                darkFactor = 0.0f;
            }
        }
    }
}

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
    }
}

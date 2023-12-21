using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BallMovement : MonoBehaviour
{
    Rigidbody rb;
    // Start is called before the first frame update
    void Start()
    {
       rb =  GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
       if(Input.GetKeyDown("space")) 
       {
        GetComponent<Rigidbody>().velocity = new Vector3(0f,5f, 0f);
       }
       if(Input.GetKey("up"))
       {
        GetComponent<Rigidbody>().velocity = new Vector3(0,0,5);
       }
              if(Input.GetKey("right"))
       {
        GetComponent<Rigidbody>().velocity = new Vector3(5,0,0);
       }
              if(Input.GetKey("down"))
       {
        GetComponent<Rigidbody>().velocity = new Vector3(0,0,-5);
       }
              if(Input.GetKey("left"))
       {
        GetComponent<Rigidbody>().velocity = new Vector3(-5,0,0);
       }
    }
}

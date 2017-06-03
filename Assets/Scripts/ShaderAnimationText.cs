using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Text))]
[RequireComponent(typeof(Material))]
public class ShaderAnimationText : MonoBehaviour
{
    Material mMaterial;
    Text mText;
    float mNextAnimStartTime;

    [SerializeField, Range(0, 5)]
    public float cAnimTime = 0.6f;

    [SerializeField, Range(0, 5)]
    public float cAnimInterval = 1f;

    // Use this for initialization
    void Awake()
    {
        mText = transform.GetComponent<Text>();
        mMaterial = mText.material;
        mNextAnimStartTime = Time.time + cAnimInterval;
        InitShader();
    }

    public void InitShader()
    {
        mMaterial.SetColor("_Color", mText.color);
        mMaterial.SetFloat("_NormalTime", 0);
        mMaterial.SetInt("_TextCount", mText.text.Length);
    }

    void OnDisable()
    {
        mMaterial.SetFloat("_NormalTime", 0);
    }

    public void Update()
    {
        if (Time.time > mNextAnimStartTime)
        {
            Animation();
            mNextAnimStartTime = Time.time + cAnimInterval;
        }
    }

    void Animation()
    {
        if (transform.GetComponent<iTween>())
        {
            Destroy(transform.GetComponent<iTween>());
        }

        iTween.ValueTo(this.gameObject, iTween.Hash(
            "delay", 0.001,
            "from", 1.0f,
            "to", 0,
            "time", cAnimTime,
            "easeType", iTween.EaseType.easeInOutCubic,
            "onupdatetarget", this.gameObject,
            "onupdate", "OnUpdateShader")
        );
    }

    void OnUpdateShader(float normalizationTime)
    {
        mMaterial.SetFloat("_NormalTime", normalizationTime);//1->0
    }
}

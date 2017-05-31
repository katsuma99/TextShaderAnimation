using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Text))]
[RequireComponent(typeof(Material))]
public class ShaderAnimationText : MonoBehaviour
{
    Material mMaterial;
    Text mText;
    float mAnimStartTime;
    float mNextAnimStartTime;
    public const float cAnimTime = 0.6f;

    // Use this for initialization
    void Awake()
    {
        mText = transform.GetComponent<Text>();
        mMaterial = mText.material;
        mNextAnimStartTime = Time.time + Random.Range(1f, 3f);
        InitShader();
    }

    public void InitShader()
    {
        mMaterial.SetColor("_Color", mText.color);
        mMaterial.SetFloat("_Val", 1);
        mMaterial.SetFloat("_Hue", 1);
        mMaterial.SetFloat("_NormalTime", 1);
        mMaterial.SetInt("_TextCount", mText.text.Length);
    }

    public void Update()
    {
        if (Time.time > mNextAnimStartTime)
        {
            Animation();
            mNextAnimStartTime = Time.time + Random.Range(0.4f, 1.2f);
        }
    }

    void Animation()
    {
        if (transform.GetComponent<iTween>())
        {
            Destroy(transform.GetComponent<iTween>());
        }

        mAnimStartTime = mNextAnimStartTime;

        iTween.ValueTo(this.gameObject, iTween.Hash(
            "delay", 0.001,
            "from", Random.Range(200, 300),
            "to", 0,
            "time", cAnimTime,
            "easeType", iTween.EaseType.easeInOutCubic,
            "onupdatetarget", this.gameObject,
            "onupdate", "OnUpdateShader")
        );
    }

    void OnUpdateShader(int hueTrans)
    {
        float normalizationTime = Mathf.InverseLerp(mAnimStartTime, mAnimStartTime + cAnimTime, Time.time); //0->1
        mMaterial.SetFloat("_NormalTime", normalizationTime);
        mMaterial.SetFloat("_Hue", hueTrans);//200~300->0
    }
}

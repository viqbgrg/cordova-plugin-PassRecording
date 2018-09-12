package cordova.plugin.PassRecording;

import android.content.Intent;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;


import cordova.plugin.PassRecording.example.ExampleActivity;
/**
 * This class echoes a string called from JavaScript.
 */
public class PassRecording extends CordovaPlugin {

    private CallbackContext callbackContext;
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
      this.callbackContext = callbackContext;
        if (action.equals("passRecordingMethod")) {
          Intent intent = new Intent(this.cordova.getActivity(), ExampleActivity.class);
          //启动activity
          this.cordova.startActivityForResult(this, intent, 0);
            return true;
        }
        return false;
    }

//    private void coolMethod(String message, CallbackContext callbackContext) {
//        if (message != null && message.length() > 0) {
//          Intent intent = new Intent(this.cordova.getActivity(), ExampleActivity.class);
//          //启动activity
//          this.cordova.startActivityForResult(this, intent, 0);
//        } else {
//            callbackContext.error("Expected one non-empty string argument.");
//        }
//    }

  //回调
  @Override
  public void onActivityResult(int requestCode, int resultCode, Intent intent) {
    super.onActivityResult(requestCode, resultCode, intent);
    if (resultCode == 101) {
      String path = intent.getStringExtra("path");
      this.callbackContext.success(path);
    } else if (resultCode == 102) {
      this.callbackContext.error("取消录音");
    } else if (resultCode == 0) {
      this.callbackContext.error("返回取消录音");
    } else {
      this.callbackContext.error("未知错误");
    }
  }
}

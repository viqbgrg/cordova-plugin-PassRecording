package cordova.plugin.PassRecording;

import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


import cordova.plugin.PassRecording.example.ExampleActivity;
import cordova.plugin.PassRecording.manager.AudioRecordButton;
import cordova.plugin.PassRecording.manager.DialogManager;
/**
 * This class echoes a string called from JavaScript.
 */
public class PassRecording extends CordovaPlugin {

    private CallbackContext callbackContext;
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
      this.callbackContext = callbackContext;
        if (action.equals("coolMethod")) {
            String message = args.getString(0);
            this.coolMethod(message, callbackContext);
            return true;
        }
        return false;
    }

    private void coolMethod(String message, CallbackContext callbackContext) {
        if (message != null && message.length() > 0) {
          Intent intent = new Intent(this.cordova.getActivity(), ExampleActivity.class);
          //启动activity
          this.cordova.startActivityForResult(this, intent, 0);
        } else {
            callbackContext.error("Expected one non-empty string argument.");
        }
    }

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

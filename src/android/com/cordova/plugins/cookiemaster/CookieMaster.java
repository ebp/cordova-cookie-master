package com.cordova.plugins.cookiemaster;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import android.util.Log;

import org.apache.http.cookie.Cookie;

import java.net.HttpCookie;

import android.webkit.CookieManager;

public class CookieMaster extends CordovaPlugin {

  private final String TAG = "CookieMasterPlugin";
  public static final String ACTION_GET_COOKIE_VALUE = "getCookieValue";
  public static final String ACTION_SET_COOKIE_VALUE = "setCookieValue";

  @Override
  public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
    try {
      if (ACTION_GET_COOKIE_VALUE.equals(action)) {
        final String url = args.getString(0);
        final String cookieName = args.getString(1);

        cordova.getThreadPool().execute(new Runnable() {
          public void run() {
            try {
              CookieManager cookieManager = CookieManager.getInstance();
              String fullCookieString = cookieManager.getCookie(url);
              if (fullCookieString == null) {
                fullCookieString = "";
              }
              String[] cookies = fullCookieString.split("; ");
              String cookieValue = null;

              for (int i = 0; i < cookies.length; i++) {
                String currentCookie = cookies[i].trim();
                if (currentCookie.matches("^\\s*\\Q" + cookieName + "\\E\\s*=\\s*")) {
                  cookieValue = cookies[i].split("=")[1].trim();
                  break;
                }
              }

              if (cookieValue != null) {
                PluginResult res = new PluginResult(PluginResult.Status.OK, cookieValue);
                callbackContext.sendPluginResult(res);
              } else {
                callbackContext.error("Cookie not found!");
              }
            } catch (Exception e) {
              Log.e(TAG, "Exception: " + e.getMessage());
              callbackContext.error(e.getMessage());
            }
          }
        });
        return true;
      } else if (ACTION_SET_COOKIE_VALUE.equals(action)) {
        final String url = args.getString(0);
        final String cookieName = args.getString(1);
        final String cookieValue = args.getString(2);
        final JSONObject cookieOptions = args.getJSONObject(3);

        cordova.getThreadPool().execute(new Runnable() {
          public void run() {
            try {
              HttpCookie cookie = new HttpCookie(cookieName, cookieValue);

              if (cookieOptions.has("path")) {
                cookie.setPath(cookieOptions.getString("path"));
              }

              if (cookieOptions.has("domain")) {
                cookie.setDomain(cookieOptions.getString("domain"));
              }

              if (cookieOptions.has("maxAge")) {
                cookie.setMaxAge(cookieOptions.getLong());
              }

              if (cookieOptions.has("secure")) {
                cookie.setSecure(cookieOptions.getBoolean());
              }

              String cookieString = cookie.toString().replace("\"", "");
              CookieManager cookieManager = CookieManager.getInstance();
              cookieManager.setCookie(url, cookieString);

              PluginResult res = new PluginResult(PluginResult.Status.OK, "Successfully added cookie");
              callbackContext.sendPluginResult(res);
            } catch (Exception e) {
              Log.e(TAG, "Exception: " + e.getMessage());
              callbackContext.error(e.getMessage());
            }
          }
        });
        return true;
      }
      callbackContext.error("Invalid action");
      return false;
    } catch (Exception e) {
      Log.e(TAG, "Exception: " + e.getMessage());
      callbackContext.error(e.getMessage());
      return false;
    }
  }
}

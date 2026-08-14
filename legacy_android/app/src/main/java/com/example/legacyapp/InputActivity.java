package com.example.legacyapp;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;

public class InputActivity extends BaseActivity {

    private static final String PREFS_NAME = "legacy_app_prefs";
    private static final String KEY_NAME = "draft_name";
    private static final String KEY_EMAIL = "draft_email";
    private static final String KEY_MESSAGE = "draft_message";

    private EditText nameEdit;
    private EditText emailEdit;
    private EditText messageEdit;
    private SharedPreferences prefs;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_input);

        prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);

        nameEdit = findViewById(R.id.editName);
        emailEdit = findViewById(R.id.editEmail);
        messageEdit = findViewById(R.id.editMessage);

        nameEdit.setText(prefs.getString(KEY_NAME, ""));
        emailEdit.setText(prefs.getString(KEY_EMAIL, ""));
        messageEdit.setText(prefs.getString(KEY_MESSAGE, ""));

        TextWatcher draftSaver = new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                saveDraft();
            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        };
        nameEdit.addTextChangedListener(draftSaver);
        emailEdit.addTextChangedListener(draftSaver);
        messageEdit.addTextChangedListener(draftSaver);

        findViewById(R.id.buttonNext).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                sFormData.name = nameEdit.getText().toString();
                sFormData.email = emailEdit.getText().toString();
                sFormData.message = messageEdit.getText().toString();
                startActivity(new Intent(InputActivity.this, ConfirmActivity.class));
            }
        });
    }

    private void saveDraft() {
        prefs.edit()
                .putString(KEY_NAME, nameEdit.getText().toString())
                .putString(KEY_EMAIL, emailEdit.getText().toString())
                .putString(KEY_MESSAGE, messageEdit.getText().toString())
                .apply();
    }
}

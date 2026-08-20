package com.example.legacyapp;

import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;

import com.google.android.material.bottomnavigation.BottomNavigationView;

import io.flutter.embedding.android.FlutterFragment;
import io.flutter.embedding.android.RenderMode;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Musicタブを開く前にエンジンを起動しておくことで、初回タップ時にも
        // 待たせない(MusicFlutterEngineHolderのcached engineパターン)。
        MusicFlutterEngineHolder.INSTANCE.warmUp(this);

        if (savedInstanceState == null) {
            showFragment(new MemoFragment());
        }

        BottomNavigationView bottomNav = findViewById(R.id.bottomNav);

        // Some Android versions ignore the edge-to-edge opt-out, so the bottom
        // nav bar can end up drawn underneath the system gesture bar. Pad it
        // by the system bar inset ourselves instead of fighting that flag.
        ViewCompat.setOnApplyWindowInsetsListener(bottomNav, (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(v.getPaddingLeft(), v.getPaddingTop(), v.getPaddingRight(), systemBars.bottom);
            return insets;
        });

        bottomNav.setOnItemSelectedListener(item -> {
            int id = item.getItemId();
            if (id == R.id.nav_memo) {
                showFragment(new MemoFragment());
                return true;
            } else if (id == R.id.nav_music) {
                // Music画面は他のネイティブUI(ActionBar/BottomNavigationView)と
                // 同じウィンドウ内で部分的に組み込まれるため、公式ドキュメントの
                // 推奨通りSurfaceViewベースの既定renderModeではなくTextureViewを使う。
                showFragment(FlutterFragment.withCachedEngine(MusicFlutterEngineHolder.ENGINE_ID)
                        .renderMode(RenderMode.texture)
                        .build());
                return true;
            }
            return false;
        });
    }

    private void showFragment(Fragment fragment) {
        getSupportFragmentManager()
                .beginTransaction()
                .replace(R.id.fragmentContainer, fragment)
                .commit();
    }
}

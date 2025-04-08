// motion_blur.fp
// Aplica un desenfoque direccional simple a la textura de entrada.

// Coordenada UV recibida desde el vertex shader
varying mediump vec2 var_texcoord0;

// La textura que contiene la escena renderizada (nuestro render target)
uniform lowp sampler2D tex0; // Nombre estándar para la primera textura

// Constantes/parámetros que enviaremos desde Lua
// El shader espera vec4 aunque solo usemos x,y (convención)
uniform mediump vec4 blur_direction; // Dirección normalizada (vec2 en x,y)
uniform mediump vec4 blur_params;    // Usaremos x para la cantidad/longitud del blur

// Número de muestras para el desenfoque (más = más suave pero más costoso)
const int NUM_SAMPLES = 8;
// Mitad de muestras para centrar el blur
const int HALF_SAMPLES = NUM_SAMPLES / 2;

void main()
{
    // Obtener dirección y cantidad de los uniforms (usando solo x, y de blur_direction y x de blur_params)
    vec2 direction = normalize(blur_direction.xy); // Asegurarse de que esté normalizado si no lo está ya
    float amount = blur_params.x;

    vec4 total_color = vec4(0.0); // Acumulador de color

    // Si la cantidad es muy pequeña, no hacer blur (optimización)
    if (amount < 0.001) {
        total_color = texture2D(tex0, var_texcoord0);
    } else {
        // Tomar múltiples muestras a lo largo de la dirección del blur
        for (int i = 0; i < NUM_SAMPLES; ++i) {
            // Calcular el offset desde el centro (-0.5 a +0.5 aprox) y escalar por la cantidad
            float offset_scale = (float(i) / float(NUM_SAMPLES - 1) - 0.5) * amount;
            // Calcular la coordenada de muestreo
            vec2 sample_coord = var_texcoord0 + direction * offset_scale;
            // Acumular el color de la muestra
            total_color += texture2D(tex0, sample_coord);
        }
        // Promediar las muestras
        total_color /= float(NUM_SAMPLES);
    }

    // Establecer el color final del píxel
    gl_FragColor = total_color;

    // Podríamos multiplicar por un 'tint' si el material lo define,
    // pero para post-fx simple no suele ser necesario.
    // gl_FragColor = total_color * tint;
}
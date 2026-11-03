// Escuridão da cena com o círculo de luz da lanterna do celular.
shader_type canvas_item;

uniform vec2 posicao_luz = vec2(960.0, 540.0);
uniform vec2 tamanho = vec2(1920.0, 1080.0);
uniform float raio = 230.0;
uniform float suavidade = 130.0;
uniform float escuridao = 0.94;

void fragment() {
	vec2 p = UV * tamanho;
	float d = distance(p, posicao_luz);
	float luz = 1.0 - smoothstep(raio - suavidade, raio, d);
	COLOR = vec4(0.0, 0.0, 0.02, escuridao * (1.0 - luz));
}

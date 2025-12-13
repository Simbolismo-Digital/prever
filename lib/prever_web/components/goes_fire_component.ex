defmodule PreverWeb.GoesFireComponent do
  use Phoenix.LiveComponent

  @refresh_minutes 15

  @impl true
  def mount(socket) do
    if connected?(socket) do
      :timer.send_interval(:timer.minutes(@refresh_minutes), self(), :refresh)
    end

    {:ok,
     socket
     |> assign(:refresh_minutes, @refresh_minutes)
     |> assign(
       :image_url,
       "https://cdn.star.nesdis.noaa.gov/GOES19/ABI/SECTOR/nsa/FireTemperature/GOES19-NSA-FireTemperature-900x540.gif"
     )}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:ts, fn -> System.system_time(:second) end)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section class="goes-fire">
      <h2>GOES-19 — Temperatura de Fogo</h2>
      <p class="subtitle">Setor: América do Sul (NSA)</p>

      <div class="image-wrapper">
        <img
          id={@id}
          src={"#{@image_url}?ts=#{@ts}"}
          alt="GOES-19 Fire Temperature - América do Sul"
        />
      </div>

      <div class="fire-temp-legend" style="max-width: 500px; font-family: Arial, sans-serif;">
        <img
          src="https://www.goes.noaa.gov/images/colorbars/ColorBar450FireTemp.png"
          alt="Color Bar Fire Temperature"
          style="width: 100%; height: auto; display: block; margin-bottom: 10px;"
        />

        <ul style="list-style: none; padding: 0; margin: 0; font-size: 14px; line-height: 1.4;">
          <li><strong>1</strong> - Fogo quente</li>
          <li><strong>2</strong> - Fogo muito quente</li>
          <li><strong>3</strong> - Fogo intenso</li>
          <li><strong>4</strong> - Fogo extremamente intenso</li>
          <li><strong>5</strong> - Marcas de queimadas</li>
          <li><strong>6</strong> - Céu limpo: terra</li>
          <li><strong>7</strong> - Céu limpo: água / neve / noite</li>
          <li><strong>8</strong> - Nuvens de água</li>
          <li><strong>9</strong> - Nuvens de gelo</li>
        </ul>
      </div>

      <p class="legend">
        Animação das últimas <strong>~8 horas</strong>.
        Áreas claras indicam anomalias térmicas compatíveis com focos de incêndio.
      </p>

      <p class="meta">
        Atualização automática a cada {@refresh_minutes} minutos.
        Latência típica: 40–90 minutos.
      </p>
    </section>
    """
  end
end

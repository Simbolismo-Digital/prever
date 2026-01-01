defmodule PreverWeb.SentinelLive do
  use PreverWeb, :live_view

  alias Prever.Sentinel

  def mount(%{"id" => id}, _session, socket) do
    geometry =
      Prever.Wildfire.BurnedArea.get!(id)
      |> Map.get(:geometry)

    before_range = "2024-06-01/2024-06-30"
    after_range = "2024-08-01/2024-09-30"

    {:ok, before_items} = Sentinel.search(geometry, before_range)
    {:ok, after_items} = Sentinel.search(geometry, after_range)

    {:ok,
     assign(socket,
       geometry: geometry,
       before_images: Enum.map(before_items, &normalize_item/1),
       after_images: Enum.map(after_items, &normalize_item/1),
       before_index: 0,
       after_index: 0
     )}
  end

  defp normalize_item(item) do
    assets = item["assets"] || %{}

    visual =
      assets["rendered_preview"] ||
        assets["preview"] ||
        assets["visual"]

    %{
      visual: visual && visual["href"],
      date: item["properties"]["datetime"]
    }
  end

  ## EVENTS ###############################################################

  def handle_event("next_before", _params, socket) do
    count = length(socket.assigns.before_images)

    idx =
      if count == 0 do
        0
      else
        rem(socket.assigns.before_index + 1, count)
      end

    {:noreply, assign(socket, before_index: idx)}
  end

  def handle_event("prev_before", _params, socket) do
    count = length(socket.assigns.before_images)

    idx =
      if count == 0 do
        0
      else
        rem(socket.assigns.before_index - 1 + count, count)
      end

    {:noreply, assign(socket, before_index: idx)}
  end

  def handle_event("next_after", _params, socket) do
    count = length(socket.assigns.after_images)

    idx =
      if count == 0 do
        0
      else
        rem(socket.assigns.after_index + 1, count)
      end

    {:noreply, assign(socket, after_index: idx)}
  end

  def handle_event("prev_after", _params, socket) do
    count = length(socket.assigns.after_images)

    idx =
      if count == 0 do
        0
      else
        rem(socket.assigns.after_index - 1 + count, count)
      end

    {:noreply, assign(socket, after_index: idx)}
  end

  ## RENDER ###############################################################

  def render(assigns) do
    ~H"""
    <div style="padding: 1rem;">
      <h2>Sentinel-2 — Before & After</h2>

      <details>
        <summary style="cursor:pointer; font-weight:bold;">
          Show / Hide Geometry
        </summary>

        <pre style="
          font-size: 0.8rem;
          margin-top: 8px;
          white-space: pre-wrap;
          word-break: break-word;
          overflow-x: hidden;
        ">
          <%= Jason.encode!(@geometry) %>
        </pre>
      </details>

      <div style="display:flex; gap: 1rem; margin-top:1rem;">
        
    <!-- BEFORE -->
        <div style="flex:1;">
          <h3>Before</h3>

          <%= if @before_images != [] do %>
            <% image = Enum.at(@before_images, @before_index) %>

            <img src={image.visual} style="width:100%; border-radius:8px;" />
            <p>{image.date}</p>

            <div style="display:flex; gap:8px; align-items:center;">
              <.button phx-click="prev_before">&lt; Prev</.button>
              <span>
                {@before_index + 1} / {length(@before_images)}
              </span>
              <.button phx-click="next_before">Next &gt;</.button>
            </div>
          <% else %>
            <p>No valid image</p>
          <% end %>
        </div>
        
    <!-- AFTER -->
        <div style="flex:1;">
          <h3>After</h3>

          <%= if @after_images != [] do %>
            <% image = Enum.at(@after_images, @after_index) %>

            <img src={image.visual} style="width:100%; border-radius:8px;" />
            <p>{image.date}</p>

            <div style="display:flex; gap:8px; align-items:center;">
              <.button phx-click="prev_after">&lt; Prev</.button>
              <span>
                {@after_index + 1} / {length(@after_images)}
              </span>
              <.button phx-click="next_after">Next &gt;</.button>
            </div>
          <% else %>
            <p>No valid image</p>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end

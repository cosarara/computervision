// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {Socket} from "phoenix"

//let socket = new Socket("/socket")

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//

let socket = null;
if (window.uid_token) {
    console.log(window.uid_token);
    socket = new Socket("/socket", {params: {token: window.uid_token}})
    // Finally, connect to the socket:
    socket.connect()
    //socket.onMessage((x) => console.log("message", x))
    socket.onClose(() => console.log("close"))

    //let channel = socket.channel()

    // Now that you are connected, you can join channels with a topic:
    //let channel = socket.channel("notification:lobby", {})
    let channel = socket.channel("notification:"+window.uid, {})
    document.channel = channel
    //let channel = socket.channel("user_socket:42", {})
    channel.join()
      .receive("ok", resp => {
          console.log("Joined successfully", resp);
          channel.push("get_status")
              .receive("ok", resp => {
                  let status = resp.status;
                  console.log("got status", status);
                  for (let id in status) {
                      if (status[id] == "error") {
                          console.log("error", id);
                          let el = $(`.img-container[data-method-name=${id}]`);
                          el.find(".lds-spinner").replaceWith("error");
                      }
                  }
              })
      })
      .receive("error", resp => { console.log("Unable to join", resp) })

    channel.on("reload", payload => {
        location.reload();
    })
    channel.on("image", payload => {
        console.log(payload);
        var image = new Image();
        image.src = `data:${payload.mime};base64,${payload.data}`;
        image.alt = "processed image";
        //let el = $(`.lds-spinner[data-method-name=${payload.method}]`);
        let el = $(`.img-container[data-method-name=${payload.method}]`);
        console.log(el);
        //el.parent().find(".rating-wrapper").show();
        el.find(".rating-wrapper").show();
        //el.replaceWith(image);
        el.find(".lds-spinner").replaceWith(image);
    })
    //channel.on("status", payload => {
    //    console.log('status', payload);
    //})
}
export default socket

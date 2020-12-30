
function Effect()
{
    this.init = function() {
        Api.meshfxMsg("spawn", 1, 0, "tri.bsm2");
        Api.meshfxMsg("spawn", 0, 0, "quad.bsm2");

        // colors:
        Api.meshfxMsg("shaderVec4", 0, 0, "0.0471 0.7098 0. 0");
        Api.meshfxMsg("shaderVec4", 0, 1, "0.8275 0.9961 0.0706 0");

        // Api.meshfxMsg("shaderVec4", 0, 2, "0 0 1 1");
        // Api.meshfxMsg("shaderVec4", 0, 3, "1 1 0 1");

        // number of colors:
        Api.meshfxMsg("shaderVec4", 0, 8, "2"); //  from 2 to 4 colors smooth gradient

        Api.showRecordButton();
    };

    this.faceActions = [];
    this.noFaceActions = [];

    this.videoRecordStartActions = [];
    this.videoRecordFinishActions = [];
    this.videoRecordDiscardActions = [];
}

function setColor(name) {
    Api.meshfxMsg("tex", 0, 0, name);
}

configure(new Effect());
